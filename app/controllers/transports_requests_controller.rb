class TransportsRequestsController < ApplicationController
  authorize_resource :except => [:new, :create, :transports_response, :reject_request, :accept_request, :cancel_request, :update, :edit]
  
  def new
    @transport = Transport.find_encoded(params[:transport_id])
    @transports_request = TransportsRequest.new(:transport_id => @transport.id)
    
    if @transport.cost > 0 && current_user.available_credits < @transport.cost
      flash[:error] = t("transports_requests.no_credits")
      redirect_to @transport
      return false
    end
    
    authorize! :new, @transports_request
    
    @back_url = transport_path(@transport)
  end
  
  def edit
    @transports_request = TransportsRequest.find(params[:id])
    @transport = @transports_request.transport
    
    authorize! :edit, @transports_request
  end
  
  def transports_response
    @transports_request = TransportsRequest.find(params[:id])
    @transport = @transports_request.transport
    authorize! :transports_response, @transports_request
    
    @back_url = transport_path(@transport)
    
    @transports_request.transporter_meet_time ||= @transport.start_time
    @transports_request.transporter_return_back_meet_time ||= @transport.return_back_start_time
  end
  
  def reject_request
    @transports_request = TransportsRequest.find(params[:id])
    @transport = @transports_request.transport
    authorize! :reject_request, @transports_request
    
    begin
      Transport.transaction do 
        
        @transports_request.update_attribute(:status, Status.rejected)
        @transports_request.user.update_attribute(:reserved_credits, @transports_request.user.reserved_credits.to_f - @transports_request.total_cost) if @transports_request.total_cost > 0
        UsersRequest.create(:user_id => @transports_request.user_id, :requester_id => @transport.user_id, :requestable => @transport, :details => "users_requests.reject_request")
        TransportMailer.reject_transport_request(@transports_request.user_id, @transports_request.id).deliver if ENABLE_MAIL_SHARE
        
        #todo
        #notify user
        
        respond_to do |format|
          format.html { redirect_to @transport, notice: t("messages.transport_request_rejected") }
          format.json { render json: @transports_request, status: :updated }
        end
      end
    rescue => e
      logger.error "Error >>> " + e.message
      logger.error e.backtrace.join("\n")
      
      flash[:error] = t("errors.unexpected_error")
      respond_to do |format|
        format.html { redirect_to @transport}
        format.json { render json: @transports_request, status: :updated }
      end
    end
  end
  
  def accept_request
    @transports_request = TransportsRequest.find(params[:id])
    @transport = @transports_request.transport
    authorize! :accept_request, @transports_request
    
    @transports_request.attributes = params[:transports_request]
    @transports_request.transporter_meet_time = "#{params[:transports_request][:transporter_meet_time]} UTC+2" unless params[:transports_request].blank? && params[:transports_request][:transporter_meet_time].blank? 
    @transports_request.transporter_return_back_meet_time = "#{params[:transports_request][:transporter_return_back_meet_time]} UTC+2" unless params[:transports_request].blank? && params[:transports_request][:transporter_return_back_meet_time].blank?
    @transports_request.status = Status.accepted
    
    begin
      Transport.transaction do
        respond_to do |format|
          if @transport.available_persons >= @transports_request.for_persons && @transports_request.save
            
            if @transports_request.total_cost > 0
              @transports_request.user.reserved_credits = @transports_request.user.reserved_credits.to_f - @transports_request.total_cost
              @transports_request.user.credits = @transports_request.user.credits.to_f - @transports_request.total_cost
              @transports_request.user.save(:validate => false)
              
              MoneyTransaction.add_transaction(@transports_request.user, MoneyTransactionType.pay_for_ride, @transports_request.total_cost, @transport)
            end
            
            if @transport.cost_type == CostType.paid && @transports_request.total_cost > 0
              @transport.user.credits = @transport.user.credits.to_f + (@transports_request.total_cost * USER_PERC)
              @transport.user.save(:validate => false)
              
              MoneyTransaction.add_transaction(@transport.user, MoneyTransactionType.collect_for_ride, (@transports_request.total_cost * USER_PERC), @transport)
              MoneyTransaction.add_transaction(nil, MoneyTransactionType.twseela_commission, @transports_request.total_cost - (@transports_request.total_cost * USER_PERC), @transport)
            end
            
            if @transport.transports_requests.accepted.count == 1
              @transport.user.mileage_sum = @transport.user.mileage_sum + @transport.mileage
              @transport.user.save(:validate => false)
            end
            
            @transport.available_persons -=  @transports_request.for_persons
            @transport.save
            
            UsersRequest.create(:user_id => @transports_request.user_id, :requester_id => @transport.user_id, :requestable => @transport, :details => "users_requests.accept_request")
            
            if @transports_request.notify_type.to_i == NotifyType.email || @transports_request.notify_type.to_i == NotifyType.email_and_sms
              TransportMailer.accept_transport_request(@transports_request.user_id, @transports_request.id).deliver if ENABLE_MAIL_SHARE
            end
            if @transports_request.notify_type.to_i == NotifyType.sms || @transports_request.notify_type.to_i == NotifyType.email_and_sms
              Resque.enqueue(SmsShare, @transports_request.user_id, :accept_transport_request, @transports_request.id)
            end
            
            if @transports_request.transport.available_persons <= 0
              #cancelall other requests
              other_rejected_msg = @transport.transports_requests.requested.size > 0 ? t("messages.transport_request_other_rejected") : ""
              @transport.transports_requests.requested.each do |transports_request|
                transports_request.update_attribute(:status, Status.rejected)
                ##verify if it working well
                transports_request.user.update_attribute(:reserved_credits, transports_request.user.reserved_credits.to_f - transports_request.total_cost) if transports_request.total_cost > 0
                UsersRequest.create(:user_id => transports_request.user_id, :requester_id => @transport.user_id, :requestable => @transport, :details => "users_requests.reject_request")
                TransportMailer.reject_transport_request(transports_request.user_id, transports_request.id).deliver if ENABLE_MAIL_SHARE
              end
            end
            
            other_requests =  @transport.transports_requests.accepted.collect(&:user_id) - [@transports_request.user_id]
            other_requests.each do |other_request|
              UserMailer.new_roadmate(other_request, @transports_request.id).deliver if ENABLE_MAIL_SHARE
            end 
            
            Resque.enqueue(ProviderShare, @transports_request.user_id, :transport_accepted_share, @transports_request.user.accounts.collect(&:provider), @transports_request.transport_id)
            
            format.html { redirect_to @transport, notice: ("#{t("messages.transport_request_accepted")} #{other_rejected_msg}") }
            format.json { render json: @transports_request, status: :updated }
          else
            flash.now[:error] = t("transports_requests.no_available_persons") if @transport.available_persons < @transports_request.for_persons
            format.html { render action: "transports_response" }
            format.json { render json: @transports_request.errors, status: :unprocessable_entity }
          end
        end
      end
    rescue => e
      logger.error "Error >>> " + e.message
      logger.error e.backtrace.join("\n")
      
      @back_url = transport_path(@transport)
      
      flash.now[:error] = t("errors.unexpected_error")
      respond_to do |format|
        format.html { render action: "transports_response" }
        format.json { render json: @transports_request.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def cancel_request
    @transports_request = TransportsRequest.find(params[:id])
    authorize! :cancel_request, @transports_request
    
    @transport = @transports_request.transport
    old_status = @transports_request.status
    
    begin
      Transport.transaction do
        if old_status == Status.requested
          if @transports_request.total_cost > 0
            @transports_request.user.reserved_credits = @transports_request.user.reserved_credits.to_f - @transports_request.total_cost
            @transports_request.user.save(:validate => false)
          end
        elsif old_status == Status.accepted
          if @transport.cost_type == CostType.paid
            if @transports_request.total_cost > 0
              @transports_request.user.credits = @transports_request.user.credits.to_f + (@transports_request.total_cost * USER_PERC)
              @transports_request.user.save(:validate => false)
              MoneyTransaction.add_transaction(@transports_request.user, MoneyTransactionType.cancel_pay_for_ride, (@transports_request.total_cost * USER_PERC), @transport)
              
              @transport.user.credits = @transport.user.credits.to_f - (@transports_request.total_cost * USER_PERC)
              @transport.user.save(:validate => false)
              MoneyTransaction.add_transaction(@transport.user, MoneyTransactionType.cancel_collect_for_ride, (@transports_request.total_cost * USER_PERC), @transport)
            end
          else
            if @transports_request.total_cost > 0
              @transports_request.user.credits = @transports_request.user.credits.to_f + (@transports_request.total_cost * USER_PERC)
              @transports_request.user.save(:validate => false)
            end 
          end
          
          @transport.available_persons +=  @transports_request.for_persons
          @transport.save
          
          #todo
          #notify user by SMS and Email
        end
        
        @transports_request.update_attribute(:status, Status.canceled)
        
        if @transport.transports_requests.accepted.count == 0 && old_status == Status.accepted
          @transport.user.mileage_sum = @transport.user.mileage_sum - @transport.mileage
          @transport.user.save(:validate => false)
        end
        
        
        UsersRequest.create(:user_id => @transport.user_id, :requester_id => @transports_request.user_id, :requestable => @transport, :details => "users_requests.cancel_request")
        UserMailer.cancel_transport_request(@transport.user_id, @transports_request.id).deliver if ENABLE_MAIL_SHARE
        
        other_requests =  @transport.transports_requests.accepted.collect(&:user_id) - [@transports_request.user_id]
        other_requests.each do |other_request|
          UserMailer.cancel_roadmate(other_request, @transports_request.id).deliver if ENABLE_MAIL_SHARE
        end 
        
      end
      respond_to do |format|
        format.html { redirect_to @transport, notice: t("messages.transport_request_canceled") }
        format.json { render json: @transports_request, status: :updated }
      end
    rescue => e
      logger.error "Error >>> " + e.message
      logger.error e.backtrace.join("\n")
      
      respond_to do |format|
        flash[:error] = t("errors.unexpected_error")
        format.html { redirect_to @transport }
        format.json { render json: @transports_request, status: :updated }
      end
    end
    
  end
  
  def create
    @transport = Transport.find_encoded(params[:transport_id])
    @transports_request = TransportsRequest.new(params[:transports_request].merge(:status => Status.requested, :transport_id => @transport.id, :user_id => current_user.id))
    authorize! :create, @transports_request
    
    @back_url = transport_path(@transport)
    @transports_request.requester_cost = @transports_request.transport.cost if @transports_request.transport.cost_type == CostType.free
    
    respond_to do |format|
      begin 
        Transport.transaction do 
          if @transport.available_persons.to_i >= @transports_request.for_persons.to_i && @transports_request.user.available_credits >= @transports_request.total_cost &&  @transports_request.save
            
            @transports_request.user.update_attribute(:reserved_credits, @transports_request.user.reserved_credits.to_f + @transports_request.total_cost) if @transports_request.total_cost > 0
            UsersRequest.create(:user_id => @transport.user_id, :requester_id => @transports_request.user_id, :requestable => @transport, :details => "users_requests.sent_request")
            
            if @transports_request.notify_type.to_i == NotifyType.email || @transports_request.notify_type.to_i == NotifyType.email_and_sms
              TransportMailer.new_transport_request(@transport.user_id, @transports_request.id).deliver if ENABLE_MAIL_SHARE
            end
            if @transports_request.notify_type.to_i == NotifyType.sms || @transports_request.notify_type.to_i == NotifyType.email_and_sms
              Resque.enqueue(SmsShare, @transport.user_id, :new_transport_request, @transports_request.id)
            end
            
            format.html { redirect_to @transport, notice: t("messages.transport_request_created") }
            format.json { render json: @transports_request, status: :created, location: @transports_request }
          else
            err_msg = t("transports_requests.no_available_persons") if @transport.available_persons.to_i < @transports_request.for_persons.to_i
            err_msg ||= t("transports_requests.no_credits") if @transports_request.user.credits < @transports_request.total_cost
            flash.now[:error] = err_msg
            format.html { render action: "new" }
            format.json { render json: @transports_request.errors, status: :unprocessable_entity }
          end
        end
      rescue => e
      logger.error "Error >>> " + e.message
      logger.error e.backtrace.join("\n")
      
        flash.now[:error] = t("errors.unexpected_error")
        format.html { render action: "new" }
        format.json { render json: @transports_request.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @transport = Transport.find_encoded(params[:transport_id])
    @transports_request = TransportsRequest.find(params[:id])
    authorize! :update, @transports_request
    @back_url = transport_path(@transport)
    
    respond_to do |format|
      if @transports_request.update_attributes(params[:transports_request])
        #todo 
        #notify users , by sms or email depends on setting and the user credits
        
        #todo
        #increase the sits count 
        format.html { redirect_to @transport, notice: t("messages.transport_request_updated") }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @transports_request.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def delete
    @transport = Transport.find_encoded(params[:transport_id])
    @transports_request = TransportsRequest.find(params[:id])
    authorize! :update, @transports_request
    
    @transports_request.destroy
    
    #todo 
    #notify users
    
    respond_to do |format|
      format.html { redirect_to @transport }
      format.json { head :ok }
    end
  end
  
  #########
  protected
  #########
  
  def set_title
    @title = t("transports_requests.transports_requests")
  end
end
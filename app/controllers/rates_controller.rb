class RatesController < ApplicationController
  skip_before_filter :set_title
  
  def new
    rateable = TransportsRequest.find(params[:transports_request_id]) unless params[:transports_request_id].blank?
    rateable ||= Transport.find_encoded(params[:transport_id]) unless params[:transport_id].blank?
    rateable ||= nil
    
    @rate = Rate.new(:user_id => current_user.id, :rateable => rateable)
    authorize! :new, @rate
    
    respond_to do |format|
      format.html
      format.json { render json: @rate }
    end
  end
  
  def edit
    @rate = Rate.find(params[:id])
    authorize! :edit, @rate
  end
  
  def create
    rateable = TransportsRequest.find(params[:transports_request_id]) unless params[:transports_request_id].blank?
    rateable ||= Transport.find_encoded(params[:transport_id]) unless params[:transport_id].blank?
    rateable ||= nil
    
    @rate = Rate.new(:rateable => rateable, :rate => params[:rate].to_i, :user => current_user)
    authorize! :create, @rate
    
    @rate.rate = 5 if @rate.rate > 5
    @rate.rate = 0 if @rate.rate < 0
    
    
    redirect_url = "/transports/#{@rate.rateable.transport.to_param}" if @rate.rateable_type == "TransportsRequest"
    redirect_url ||= "/#{@rate.rateable_type.downcase.pluralize}/#{@rate.rateable.to_param}" if @rate.rateable_type == "Transport"
    redirect_url ||= "/#{@rate.rateable_type.downcase.pluralize}"
    
    
    respond_to do |format|
      if @rate.save
        
        Notification.create(:user => current_user , :notifiable => @rate.rateable_type == "TransportsRequest" ? @rate.rateable.transport : @rate.rateable, :notification => "notifications.added_rate")
        
        #todo 
        #notify users

        format.html { redirect_to redirect_url, notice: t("messages.rate_created") }
        format.json { render json: @rate, status: :created, location: @rate }
      else
        format.html { render action: "new" }
        format.json { render json: @rate.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update
    rateable = Transport.find_encoded(params[:transport_id]) unless params[:transport_id].blank?
    @rate = Rate.find(params[:id])
    authorize! :update, @rate
    
    @rate.rate = params[:rate].to_i
    @rate.rate = 5 if @rate.rate > 5
    @rate.rate = 0 if @rate.rate < 0
    
    
    redirect_url = "/transports/#{@rate.rateable.transport.to_param}" if @rate.rateable_type == "TransportsRequest"
    redirect_url ||= "/#{@rate.rateable_type.downcase.pluralize}/#{@rate.rateable.to_param}" if @rate.rateable_type == "Transport"
    redirect_url ||= "/#{@rate.rateable_type.downcase.pluralize}"
    
    
    respond_to do |format|
      if @rate.save
        
        #todo 
        #notify users
    
        format.html { redirect_to redirect_url, notice: t("messages.rate_updated") }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @rate.errors, status: :unprocessable_entity }
      end
    end
  end
end
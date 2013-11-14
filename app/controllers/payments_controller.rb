class PaymentsController < ApplicationController
  load_and_authorize_resource
  
  def index
    @payments = Payment.all
    
    respond_to do |format|
      format.html
      format.json { render json: @payments }
    end
  end

  def show
    @payment = Payment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @payment }
    end
  end
  
  def new
    @payment = Payment.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @payment }
    end
  end

  # GET /payments/1/edit
  def edit
    @payment = Payment.find(params[:id])
  end

  def create
    @payment = Payment.new(params[:payment])
    
    @payment.status_id = Status.requested
    @payment.user_id = current_user.id
    @payment.session_id = Time.now.to_i.to_s
    @payment.token = Cashu.generate_token(@payment.amount)
    
    
    respond_to do |format|
      if @payment.save
        format.html { redirect_to confirm_payment_path(@payment)}
        format.json { render json: @payment, status: :created, location: @payment }
      else
        format.html { render action: "new" }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  def confirm 
    @payment = Payment.find(params[:id])
  end
  
  def cashu_approved
    begin
      @payment = Payment.find_by_session_id_and_token(params[:session_id], params[:token])
      
      rais "Invalid Verification String" if params[:verificationString].blank? || params[:verificationString] != Cashu.generate_verification_string(params[:trn_id])
      rais "Payment details not found" if @payment.nil?
      
      Payment.transaction do
        @payment.status_id = Status.accepted
        @payment.transaction_id = params[:trn_id]
        @payment.save
        
        MoneyTransaction.add_transaction(@payment.user, MoneyTransactionType.recharge, @payment.amount, @payment)
        
        @payment.user.credits = @payment.user.credits.to_f + @payment.amount
        @payment.user.save(:validate => false)
        PaymentMailer.payment_success(@payment.id).deliver
      end
      
      @page_name = "valid_trans"
      render :status => :ok, :layout => false
      # redirect_to SITE_URL + "/valid_trans" #, notice: t("messages.payment_added")
    rescue => e
      Rails.logger.error " > > > > > > > > >  > > > > > > > > >  > > > > > > > > > "
      Rails.logger.error " Error : #{e.message}"
      PaymentMailer.payment_error(@payment.id, e.message, params[:trn_id], params[:verificationString]).deliver
      @page_name = "invalid_trans"
      render :file => 'public/invalid_trans.html', :status => 200, :layout => false
      # redirect_to SITE_URL + "/invalid_trans" #, notice: " Error : #{e.message}"
    end
  end
  
  def cashu_sorry
    Rails.logger.info " > > > > > > > > >  > > > > > > > > >  > > > > > > > > > "
    Rails.logger.info " error code : #{params[:errorCode]}"
    Rails.logger.info " > > > > > > > > >  > > > > > > > > >  > > > > > > > > > "
    
    @payment = Payment.find_by_session_id(params[:session_id])
    @payment.destroy if @payment
    
    #flash[:error] = t("cashu_errors.error_#{params[:errorCode]}")
    #redirect_to SITE_URL + "/invalid_trans"
    render :file => 'public/invalid_trans.html', :status => 200, :layout => false
  end
  
  
  # PUT /payments/1
  # PUT /payments/1.json
  def update
    @payment = Payment.find(params[:id])

    respond_to do |format|
      if @payment.update_attributes(params[:payment])
        format.html { redirect_to @payment, notice: 'Payment was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @payment = Payment.find(params[:id])
    @payment.destroy

    respond_to do |format|
      format.html { redirect_to new_payment_url }
      format.json { head :ok }
    end
  end
  
  #########
  protected
  #########
  
  def set_title
    @title = t("payments.payments")
  end
end
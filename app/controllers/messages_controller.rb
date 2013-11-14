class MessagesController < ApplicationController
  def index
    authorize! :index, Message.new(:sender_id => params[:user_id])
    
    if params[:user_id].blank?
      @messages = current_user.received_messages.where("created_at >= '#{session[:last_time_to_check_messages] || current_user.before_last_login || current_user.last_login || Time.now}'")
      session[:last_time_to_check_messages] = Time.now
    else
      user = User.find(params[:user_id])
      @messages = user.received_messages.page(params[:page]).per(Message.per_page)
    end
    
    respond_to do |format|
      format.html 
      format.json { render json: @messages }
      format.js
    end
  end
  
  def sent
    authorize! :sent, Message.new(:sender_id => params[:user_id])
    
    user = User.find(params[:user_id])
    @messages = user.sent_messages.page(params[:page]).per(Message.per_page)
    
    respond_to do |format|
      format.html 
      format.json { render json: @messages }
      format.js
    end
  end
  def show
    @message = Message.find(params[:id])

    respond_to do |format|
      format.html {render :layout => (params[:layout] != "false")}
      format.json { render json: @message }
    end
  end
  
  def new
    @message = Message.new(:sender_id => params[:user_id], :recipient_id => params[:recipient_id])
    authorize! :new, @message
    
    respond_to do |format|
      format.html {render :layout => (params[:layout] != "false")}
      format.json { render json: @message }
    end
  end

  def create
    @message = Message.new(params[:message])
    authorize! :create, @message

    respond_to do |format|
      if @message.save
        format.html { redirect_to @message.recipient, notice: t("user_messages.sent") }
        format.json { render json: @message.recipient, status: :created, location: @message.recipient }
      else
        format.html { render action: "new" }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # DELETE /messages/1
  # DELETE /messages/1.json
  def destroy
    @message = Message.find(params[:id])
    @message.destroy

    respond_to do |format|
      format.html { redirect_to messages_url }
      format.json { head :ok }
    end
  end
  
  #########
  protected
  #########
  
  def set_title
    @title = t("user_messages.send_message")
  end
end

class NotificationsController < ApplicationController
  def index
    authorize! :index, Notification.new(:user_id => params[:user_id])
    
    if params[:user_id].blank?
      @notifications = Notification.where(:user_id => current_user.friends_ids).where("user_id <> #{current_user.id}").where("created_at >= '#{session[:last_time_to_check_notifications] || current_user.before_last_login || current_user.last_login || Time.now}'")
      session[:last_time_to_check_notifications] = Time.now
    else
      user = User.find(params[:user_id])
      @notifications = Notification.where(:user_id => user.friends_ids).where("user_id <> #{params[:user_id]}").page(params[:page]).per(Notification.per_page)
    end
    
    respond_to do |format|
      format.html
      format.json { render json: @notifications }
      format.js
    end
  end
  
  #########
  protected
  #########
  
  def set_title
    @title = t("messages.notifications")
  end
end
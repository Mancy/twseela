class UsersRequestsController < ApplicationController
  def index
    authorize! :index, UsersRequest.new(:user_id => params[:user_id])
    
    if params[:user_id].blank?
      @users_requests = current_user.users_requests.where("created_at >= '#{session[:last_time_to_check_users_requests] || current_user.before_last_login || current_user.last_login || Time.now}'")
      session[:last_time_to_check_users_requests] = Time.now
    else
      user = User.find(params[:user_id])
      @users_requests = user.users_requests.page(params[:page]).per(UsersRequest.per_page)
    end
    
    respond_to do |format|
      format.html
      format.json { render json: @users_requests }
      format.js
    end
  end
  
  #########
  protected
  #########
  
  def set_title
    @title = t("messages.users_requests")
  end
end
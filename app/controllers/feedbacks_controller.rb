class FeedbacksController < ApplicationController
  caches_action :new, :layout => true, :expires_in => CACHE_EXPIRES_IN.call
  
  def new
    @feedback = Feedback.new
    
    respond_to do |format|
      format.html {render :layout => (params[:layout] != "false")}
      format.json { render json: @feedback }
    end
  end
  
  def create
    @feedback = Feedback.new(params[:feedback])
    
    @feedback.email = current_user.email if current_user
    
    if validate_recap(params, @feedback.errors) && @feedback.save
      redirect_to root_path, :notice => t("messages.feedback_sent")
    else
      render :action => "new"
    end
  end
  
  #########
  protected
  #########
  
  def set_title
    @title = t("sidebar.feedback")
  end
end

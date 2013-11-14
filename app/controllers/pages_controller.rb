class PagesController < ApplicationController
  caches_action :show, :layout => true, :expires_in => CACHE_EXPIRES_IN.call, :if => Proc.new{|x| !current_user || (params[:id].to_sym != :home && params[:id].to_sym != :invite_friends) }
  
    
  def show
    # session[:account_id] = 1
    
    # Rails.logger.info " > > > > > #{session[:last_time_to_check_notifications]}"
    # Rails.logger.info " > > > > > #{current_user.before_last_login || current_user.last_login}" if current_user
    
    
    if params[:id].to_sym == :home
      if current_user
        @users = User.order("created_at desc").where("id <> #{current_user.id}")
        @users = @users.where("id in (#{current_user.friends_ids.join(',')})").limit(15)
        
        @transports = current_user.transports.order("start_time desc").limit(5)
        @transports_requests = current_user.transports_requests.order("created_at desc").limit(5)
      else
        # @transports = Transport.order("created_at desc").limit(10)
        @transports = Transport.where("start_place <> '' and end_place <> '' ").rand(15)
      end 
    elsif params[:id].to_sym == :invite_friends
      if current_user
        @users = User.order("created_at desc").where("id <> #{current_user.id}")
        @users = @users.where("id in (#{current_user.friends_ids.join(',')})").limit(15)
      end
    end
    
    respond_to do |format|
      format.html { render :template => "pages/#{params[:id].to_s.downcase}", :layout => (params[:layout] != "false") }
    end
    
  end
  
  #########
  protected 
  #########
  
  def set_title
    @title = t("pages.#{params[:id]}")
  end
end
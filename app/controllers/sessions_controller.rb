class SessionsController < ApplicationController
  skip_before_filter :set_title
  skip_before_filter :validate_user, :only =>[:destroy, :login_header]
  before_filter :store_return_to, :only => [:destroy, :admin_login, :login, :volunteering]
  
  def create
    #check if the user has a permission of poting to facebook
    if auth_hash["provider"] == "facebook" && !ProviderShare.user_has_permissions(auth_hash["credentials"]["token"])
      if auth_origin == "mobile_login"  || params[:state] == "mobile_login" || request_referer_type == "web_login" || params[:state] == "web_login"
        redirect_to "/mobile/views/sessions/login_failure"
        #redirect_to page_path(:login_failed)
      else
        flash[:error] = t("messages.permission_failure")
        redirect_to "/"
      end
      return false
    end
    
    @account = Account.initialize_with_omniauth(auth_hash)
    
    #update the token and the secret after each login
    #todo, check the update token after login
    unless @account.id.blank?
      @account.provider_token = auth_hash["credentials"]["token"]
      @account.provider_secret = auth_hash["credentials"]["secret"]
      @account.save
    end
    
    if current_user && auth_origin != "mobile_login" && params[:state] != "mobile_login" && auth_origin != "web_login" && params[:state] != "web_login"
      if @account.id.blank?
        @account.user = current_user
        @account.save
        Resque.enqueue(ProviderFriends, @account.id)
        Resque.enqueue(ProviderShare, @account.user.id, :register_share, [@account.provider])
        @account.user.reset_friends_ids_cache
      end
      redirect_to merge_accounts_user_path(current_user), :notice => t("messages.account_merged")
    else
      #update account's user 
      @account.user ||= User.initialize_with_omniauth(auth_hash)
      
      if @account.new_record?
        @carsmakes = CarsMake.all
        @gasoline_type = GasolineType.all
        @cities = City.all
        
        @account.user.has_car = false
        @account.user.default_locale = I18n.locale.to_s 
        @title = t("users.new_user")
        
        if auth_origin == "mobile_login" || params[:state] == "mobile_login" || auth_origin == "web_login" || params[:state] == "web_login"
          login_attrs = {:provider => @account.provider, 
			:uid => @account.uid, 
			:image => @account.image, 
			:provider_token => @account.provider_token, 
			:provider_secret => @account.provider_secret, 
			:name => @account.user.name, 
			:email => @account.user.email, 
			:gender => @account.user.gender,
			:cities_list => City.select("id, name_ar").collect{ |c| {:id => c.id, :name => c.name_ar}}, 
			:cars_makes_list => CarsMake.select("id, name_ar").collect{ |m| {:id => m.id, :name => m.name_ar}},
			:gasoline_types_list => GasolineType.select("id, name_ar").collect{ |t| {:id => t.id, :name => t.name_ar}}
			}
          session[:login_attrs] = login_attrs
          #redirect_to page_path(:new_login) + "?_csrf_token=#{session["_csrf_token"]}"
          redirect_to "/mobile/views/sessions/new_login"
        else
          render :new
        end
      else
        session[:account_id] = @account.id
        @account.user.last_login = Time.now
        @account.user.save(:validate => false)
        @account.user.reset_friends_ids_cache

        if auth_origin == "mobile_login"  || params[:state] == "mobile_login" || auth_origin == "web_login"  || params[:state] == "web_login"
	  redirect_to "/mobile/views/sessions/login_success"
          #redirect_to page_path(:login_success) + "?_csrf_token=#{session["_csrf_token"]}"
        else
          flash[:notice] = t("messages.logged_in")
          redirect_to_return
        end
      end
    end
  end
  
  def destroy
    session[:account_id] = nil
    
    if session[:return_to].match(/\/admin/)
      session[:return_to] = "/"
    end
    
    
    
    respond_to do |format|
      format.html do 
        flash[:notice] = t("messages.logged_out")
        redirect_to root_path
      end
      format.json { render json: {}, status: 200 }
    end
  end
  
  def login
    @title = t("navigation.login")
    if !params[:provider].blank?
      redirect_to "/auth/#{params[:provider]}"
      return true
    elsif current_user
      redirect_to merge_accounts_user_path(current_user), :notice => t("messages.logged_in_before")
      return true
    end
    
    respond_to do |format|
      format.html {render :layout => (params[:layout] != "false")}
    end
  end
  
  def mobile_login
    #session[:account_id] = 1
    #redirect_to "/mobile/views/sessions/login_success"


    session[:request_referer] = params[:login_type]
    if params[:provider] == "facebook"
     redirect_to "http://www.facebook.com/dialog/oauth/?client_id=#{OMNIAUTH_CONFIG[:facebook]["key"]}&redirect_uri=#{SITE_URL}/auth/facebook/callback&state=#{params[:login_type]}&scope=#{OMNIAUTH_CONFIG[:facebook]["scope"]}&origin=#{params[:login_type]}"
    else
      redirect_to "/auth/#{params[:provider]}?origin=#{params[:login_type]}"
    end



    
    # if current_user
    #   redirect_to merge_accounts_user_path(current_user), :notice => t("messages.logged_in")
    # end
  end
  
  def failure
    if params[:message] == "invalid_credentials"
      request_referer_type = session[:request_referer]
      session[:request_referer] = nil
      
      if request_referer_type == "mobile_login" || request_referer_type == "web_login"
        redirect_to "/mobile/views/sessions/login_failure"
      else
        flash[:error] = t("messages.login_failure")
        redirect_to "/?failure=invalid_credentials"
      end
    else
      redirect_to_return
    end 
  end
  
  def login_header
    if current_user
      @head_requests_count = current_user.users_requests.where("created_at >= '#{session[:last_time_to_check_users_requests] || current_user.before_last_login || current_user.last_login || Time.now}'").count
      @head_notifications_count = Notification.where(:user_id => current_user.friends_ids).where("user_id <> #{current_user.id}").where("created_at >= '#{session[:last_time_to_check_notifications] || current_user.before_last_login || current_user.last_login || Time.now}'").count
      @head_messages_count = current_user.received_messages.not_checked.where("created_at >= '#{session[:last_time_to_check_messages] || current_user.before_last_login || current_user.last_login || Time.now}'").count
      
      @head_requests_count = nil if @head_requests_count.to_i < 1
      @head_notifications_count = nil if @head_notifications_count.to_i < 1
      @head_messages_count = nil if @head_messages_count.to_i < 1
    end 
    
    respond_to do |format|
      format.js
    end
  end
  
  #######
  private
  #######
  
  def auth_hash
    request.env['omniauth.auth']
  end
  
  def auth_origin
    request.env['omniauth.origin']
  end
  
  def store_return_to
    return_path = request.env["HTTP_REFERER"] || "/" 
    return_path = return_path.match(/\/login/) ? "/" : return_path
    session[:return_to] = return_path
  end
  
  def redirect_to_return
    return_to_path = session[:return_to] || "/"
    session[:return_to] = nil
    redirect_to return_to_path
  end
end

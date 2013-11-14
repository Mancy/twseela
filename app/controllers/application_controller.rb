class ApplicationController < ActionController::Base
  before_filter :validate_user
  before_filter :set_locale, :set_title, :set_description, :set_variables
  after_filter :save_flash_to_cookies
  
  protect_from_forgery
  helper_method :current_account, :current_user
  include ReCaptcha::AppHelper
  
  def default_url_options(options={})
    # { :locale => I18n.locale }
    { :locale => :ar }
  end
  
  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html do
        if !current_user
          flash[:error] = t("messages.please_login")
          redirect_to root_path 
        else
          flash[:error] = exception.message
          redirect_to root_path
        end
      end
      format.json {render json: [t("errors.not_authorized")], status: 500}
    end
    
  end
  
  def set_admin_locale
    I18n.locale = :en
  end
  
  #######
  private
  #######
  
  def validate_user
    if current_user && !current_user.valid?
      flash[:error] = t("messages.edit_your_profile_first")
      redirect_to edit_user_path(current_user)
    end
  end
  
  def current_account  
    @current_account ||= (Account.where("id = #{session[:account_id]}").first) if session[:account_id]
  end  
  
  def current_user
    current_account.user if current_account
  end
  
  def set_locale
    session[:locale] = params[:locale]
    # I18n.locale = session[:locale] 
    I18n.locale = :ar
  end
  
  def set_variables
    # if cookies[:last_welcome_message].blank?
      @welcome_message = t("welcome_message.msg_4") 
      cookies[:last_welcome_message] = { :value => Time.now, :expires => Time.now + 7.day}
      cookies.delete :welcome_message_appeared if cookies[:welcome_message_appeared] && cookies[:welcome_message_appeared].length == 0
    # end
  end
  
  def save_flash_to_cookies
    #if CACHED_CONTROLLERS.include?(params[:controller].to_sym) && CACHED_Actions[params[:controller].to_sym] && CACHED_Actions[params[:controller].to_sym].include?(params[:action].to_sym)
      [:error, :notice, :warning].each do |f|
        cookies["flash_#{f}".to_sym] = flash[f.to_sym] if flash[f]
      end
    #end
  end
  
  def set_description
    @description = t("share.dsc")
  end
end

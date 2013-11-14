Tawseela::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true
  
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.default_url_options = { :host => "www.temporary.com", :locale => :ar }
    
  config.action_mailer.smtp_settings = {
    :address              => "smtp.gmail.com",
    :port                 => 587,
    :domain               => 'temporary.com',
    :user_name            => 'tawseela@gmail.com',
    :password             => 'Tawseela123',
    :authentication       => 'plain',
    :enable_starttls_auto => true  }
  
  SITE_URL = "http://192.168.0.50:3000"
  INIT_CREDITS = 5
  FEEDBACK_EMAIL = "feedback@temporary.com"
  ADMIN_EMAIL = "temporary@gmail.com"
  ENABLE_PROVIDER_SHARE = false
  ENABLE_SMS_SHARE = false
  ENABLE_MAIL_SHARE = true
  DEFAULT_IS_FREE = true
end

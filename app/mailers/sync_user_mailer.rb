class SyncUserMailer < ActionMailer::Base
  helper ActionView::Helpers::UrlHelper
  
  layout 'email'
  default :from => "temporary Users <users@temporary.com>"
  
  def friends_counts(user, friends_count, latest_friends)
    @user = user
    @friends_count = friends_count
    @latest_friends = latest_friends 
    
    mail(:to => @user.email,
         :subject => t("user_mailer.friends_counts.subject"))
  end
  
  def new_friends_counts(user, friends_count, latest_friends)
    @user = user
    @friends_count = friends_count
    @latest_friends = latest_friends 
    
    mail(:to => @user.email,
         :subject => t("user_mailer.new_friends_counts.subject"))
  end
  
  def transports_counts(user)
    @user = user
    
    mail(:to => @user.email,
         :subject => t("user_mailer.transports_counts.subject"),
         :from => "temporary Transports <transports@temporary.com>" )
  end
end
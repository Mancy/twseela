class SyncTransportMailer < ActionMailer::Base
  layout 'email'
  default :from => "temporary Transports <transports@temporary.com>"
  
  def new_transport(transport, email)
    @transport = transport
    
    mail(:to => email,
         :subject => t("user_mailer.new_transport.subject"))
  end
  
  def new_transport_added(user, transport, emails_count)
    @user = user
    @transport = transport
    @emails_count = emails_count 
    
    mail(:to => @user.email,
         :subject => t("user_mailer.new_transport_added.subject"))
  end
end
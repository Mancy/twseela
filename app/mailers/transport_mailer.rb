class TransportMailer < AsyncMailer
  layout 'email'
  default :from => "temporary Transports <transports@temporary.com>"
  
  def new_transport_request(user_id, transport_request_id)
    @user = User.find(user_id)
    @transport_request = TransportsRequest.find(transport_request_id)
    @transport = @transport_request.transport
    
    mail(:to => @user.email,
         :subject => t("user_mailer.new_transport_request.subject"))
  end
  
  def accept_transport_request(user_id, transport_request_id)
    @user = User.find(user_id)
    @transport_request = TransportsRequest.find(transport_request_id)
    @transport = @transport_request.transport
    
    mail(:to => @user.email,
         :subject => t("user_mailer.accept_transport_request.subject"))
  end
  
  def reject_transport_request(user_id, transport_request_id)
    @user = User.find(user_id)
    @transport_request = TransportsRequest.find(transport_request_id)
    @transport = @transport_request.transport
    
    mail(:to => @user.email,
         :subject => t("user_mailer.reject_transport_request.subject"))
  end
  
  def system_reject_transport_request(user_id, transport_request_id)
    @user = User.find(user_id)
    @transport_request = TransportsRequest.find(transport_request_id)
    @transport = @transport_request.transport
    
    mail(:to => @user.email,
         :subject => t("user_mailer.system_reject_transport_request.subject"))
  end
  
  def new_transport(transports, emails)
    @user = User.find(user_id)
    @transport_request = TransportsRequest.find(transport_request_id)
    @transport = @transport_request.transport
    
    mail(:to => @user.email,
         :subject => t("user_mailer.new_transport_request.subject"))
  end
end
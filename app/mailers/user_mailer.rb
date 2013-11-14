class UserMailer < AsyncMailer
  layout 'email'
  default :from => "temporary Users <users@temporary.com>"
  
  def welcome(user_id)
    @user = User.find(user_id)
    
    mail(:to => @user.email,
         :subject => t("user_mailer.welcome.subject"))
  end
  
  def cancel_transport_request(user_id, transport_request_id)
    @user = User.find(user_id)
    @transport_request = TransportsRequest.find(transport_request_id)
    
    mail(:to => @user.email,
         :subject => t("user_mailer.cancel_transport_request.subject"))
  end
  
  def new_roadmate(user_id, transport_request_id)
    @user = User.find(user_id)
    @transport_request = TransportsRequest.find(transport_request_id)
    
    mail(:to => @user.email,
         :subject => t("user_mailer.new_roadmate.subject"))
  end
  
  def cancel_roadmate(user_id, transport_request_id)
    @user = User.find(user_id)
    @transport_request = TransportsRequest.find(transport_request_id)
    
    mail(:to => @user.email,
         :subject => t("user_mailer.cancel_roadmate.subject"))
  end
end
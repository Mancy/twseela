class PaymentMailer < AsyncMailer
  layout 'email'
  default :from => "temporary Feedback <feedback@temporary.com>"
  
  def payment_success(payment_id)
    @payment = Payment.find(payment_id)
    
    mail(:to => ADMIN_EMAIL,
         :subject => t("payment_mailer.payment_success.subject"))
  end
  
  def payment_error(payment_id, error, trans_id, verification_string)
    @payment = Payment.find(payment_id)
    @error = error
    @trans_id = trans_id
    @verification_string = verification_string
    
    mail(:to => ADMIN_EMAIL,
         :subject => t("payment_mailer.payment_error.subject"))
  end
end
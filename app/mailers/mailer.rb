class Mailer < AsyncMailer
  layout 'email'
  default :from => "temporary Feedback <feedback@temporary.com>"
  
  def feedback_email(feedback_title,feedback_body,feedback_email)
    @title = feedback_title
    @msg = feedback_body
    @email = feedback_email
    mail(:to => FEEDBACK_EMAIL,
         :subject => "[temporary #{Rails.env} Feedback] #{@title}",
         :reply_to => @email||nil)
  end
  
  def newsletter_email(newsletter_id, email)
    @newsletter = Newsletter.find(newsletter_id)
    
    mail(:to => email,
         :subject => @newsletter.title)
  end
end
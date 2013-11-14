class NotifyType
  @@email=1
  @@sms=2
  @@email_and_sms=3
  
  def self.email
    @@email
  end
  def self.sms
    @@sms
  end
  def self.email_and_sms
    @@email_and_sms
  end
end
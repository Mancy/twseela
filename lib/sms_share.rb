class SmsShare
  @queue = SERVER_IP
  
  def self.perform(user_id, method_name, obj_id = nil)
    user = User.find(user_id)
    
    if ENABLE_SMS_SHARE
      SmsShare.new(user).send(method_name, obj_id) if obj_id
    end
  end
  
  def initialize(user)
    @user = user
  end
  
  def new_transport_request(obj_id)
  end
  
  def accept_transport_request(obj_id)
  end
end
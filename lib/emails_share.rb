class EmailsShare
  @queue = SERVER_IP
  
  def self.perform(method_name, transport_id, transport_request_id=nil)
    transport = Transport.find(transport_id)
    EmailsShare.new(transport).send(method_name)
  end
  
  def initialize(transport)
    @transport = transport
    @user = @transport.user
  end
  
  def new_transport
    emails_list = []
    
    User.new_transports_notifications.where("id <> #{@user.id}").each do |user|
      emails_list << user.email if user.friends_ids.include?(@user.id)
    end
    
    if emails_list.size > 0
      emails_list.each do |mail|
        begin
          SyncTransportMailer.new_transport(@transport, mail).deliver
        rescue => e
          puts " Error > > > > > user : #{mail}"
          puts " Error > > > > > e : #{e.message}"
          puts " Error > > > > > e : #{e.backtrace}"
        end
      end
      SyncTransportMailer.new_transport_added(@user, @transport, emails_list.size).deliver
    end
  end
  
end
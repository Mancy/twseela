class ProviderFriends
  @queue = SERVER_IP
  
  def self.perform(account_id)
    @account = Account.find(account_id)
    
    response = update_provider(@account)
    res = JSON.parse(response)
    node_id = nil
    
    if res && res[0] && res[0]["id"] == 0 
      node_id = res[0]["from"].split("/")[2]
    end
    
    if node_id.blank? && res && res[0] && res[0]["body"]
      node_id = res[0]["body"]["self"].split("/").last
    end
    
    if node_id
      @account.node_id ||= node_id 
      @account.last_update = Time.now
      @account.save
      #todo remove this line to another place
      @account.user.reset_friends_ids_cache
      
      #reset friends list
      User.where("id <> #{@account.user.id}").where("id in (#{@account.user.friends_ids.join(',')})").each do |u|
        u.reset_friends_ids_cache
        # u.friends_ids
      end
    end
    
    
    # update other accounts for the same user
    # @account.user.accounts do |account|
    #   if account.last_update >= 15.days.ago && account.id != @account.id
    #     update_provider(account)
    #     account.update_attribute(:last_update, Time.now)
    #   end
    # end
  end
  
  def self.update_provider(account)
    if account.node_id.blank? || account.last_update.blank? || (!account.last_update.blank? && account.last_update <= Date.today - 7.days)
      res = ProviderFriends.update_facebook_friends(account) if account.provider == "facebook"
      res = ProviderFriends.update_twitter_friends(account) if account.provider == "twitter"
      res = ProviderFriends.update_linked_in_friends(account) if account.provider == "linked_in"
    end
    return res || "{}"
  end
  
  def self.update_twitter_friends(account)
    Twitter.configure do |config|
      config.consumer_key = OMNIAUTH_CONFIG[:twitter]["key"]
      config.consumer_secret = OMNIAUTH_CONFIG[:twitter]["secret"]
      config.oauth_token = account.provider_token
      config.oauth_token_secret = account.provider_secret
    end
    
    cursor_ids = Twitter.friend_ids(account.uid.to_i)
    ids = cursor_ids.ids unless cursor_ids.ids.blank?
    Graphdb.update_friends_list(account, ProviderFriends.get_friends_uids_only(ids), "friend")
    
    
    cursor_ids = Twitter.follower_ids(account.uid.to_i)
    ids = cursor_ids.ids unless cursor_ids.ids.blank? 
    Graphdb.update_friends_list(account, ProviderFriends.get_friends_uids_only(ids), "follower")
  end
  
  def self.update_linked_in_friends(account)
    client = LinkedIn::Client.new(OMNIAUTH_CONFIG[:linked_in]["key"], OMNIAUTH_CONFIG[:linked_in]["secret"])
    client.authorize_from_access(account.provider_token, account.provider_secret)
    friends = client.connections[:all].collect{|c| c.id}
    Graphdb.update_friends_list(account, ProviderFriends.get_friends_uids_only(friends), "friend")
  end
  
  def self.update_facebook_friends(account)
    user = FbGraph::User.fetch(account.uid, :access_token => account.provider_token)
    friends = ProviderFriends.facebook_friends(user, account.user.trust_level, 1)
    Graphdb.update_friends_list(account, ProviderFriends.get_friends_uids_only(friends), "friend")
  end
  
  def self.facebook_friends(user, target_level, current_level)
    friends_ids = user.friends.collect{|f| f.identifier}
    
    # if target_level >= current_level
    #   user.friends.each do |friend|
    #     friends_ids.merge(ProviderFriends.facebook_friends(friend, target_level , current_level + 1))
    #   end
    # end
    
    return friends_ids
  end
  
  def self.get_friends_uids_only(friends)
    friends.push("0")
    Account.where(:uid => friends.collect{|f| "#{f}"}).collect(&:uid)
  end
end
class ProviderShare
  include ActionView::Helpers::TextHelper
  
  @queue = SERVER_IP
  
  def self.perform(user_id, method_name, for_accounts, obj_id = nil)
    user = User.find(user_id)
    
    if ENABLE_PROVIDER_SHARE
      if obj_id
        ProviderShare.new(user).send(method_name, for_accounts, obj_id)
      else
        ProviderShare.new(user).send(method_name, for_accounts)
      end
    end
  end
  
  def initialize(user)
    @user = user
  end
  
  def register_share(for_accounts)
    share(for_accounts, {:msg => I18n.t("share.register.msg"), :dsc => I18n.t("share.dsc"), :link => SITE_URL, :name => I18n.t('tawseela_with_slogan'), :picture => SITE_URL + "/images/main/small_car.png" })
  end
  
  def transport_share(for_accounts, transport_id)
    transport = Transport.find(transport_id)
    share(for_accounts, {:msg => I18n.t("share.transport.msg"), :dsc => I18n.t("share.dsc"), :link => SITE_URL + "/transports/" + transport.to_param, :name => " #{truncate(transport.title, :length => 55, :separator => ' ', :omission => '...')} : #{transport.start_time.to_date.day}-#{transport.start_time.to_date.month}-#{transport.start_time.to_date.year} " , :picture => SITE_URL + "/images/main/small_car.png" })
  end
  
  def transport_accepted_share(for_accounts, transport_id)
    transport = Transport.find(transport_id)
    share(for_accounts, {:msg => I18n.t("share.transport_accepted.msg"), :dsc => I18n.t("share.dsc"), :link => SITE_URL + "/transports/" + transport.to_param, :name => " #{truncate(transport.title, :length => 55, :separator => ' ', :omission => '...')} : #{transport.start_time.to_date.day}-#{transport.start_time.to_date.month}-#{transport.start_time.to_date.year} " , :picture => SITE_URL + "/images/main/small_car.png" })
  end
  
  def invite_friends(for_accounts)
    share(for_accounts, {:msg => I18n.t("share.invite.msg"), :dsc => I18n.t("share.dsc"), :link => SITE_URL, :name => I18n.t('tawseela_with_slogan'), :picture => SITE_URL + "/images/main/small_car.png" })
  end
  
  def share(for_accounts, options = {})
    @user.accounts.each do |account|
      linked_in_share(account, options) if for_accounts.include?("linked_in") && account.provider == "linked_in"
      twitter_share(account, options) if for_accounts.include?("twitter") && account.provider == "twitter"
      facebook_share(account, options) if for_accounts.include?("facebook") && account.provider == "facebook"
    end
  end
  
  def linked_in_share(account, options)
    client = LinkedIn::Client.new(OMNIAUTH_CONFIG[:linked_in]["key"], OMNIAUTH_CONFIG[:linked_in]["secret"])
    client.authorize_from_access(account.provider_token, account.provider_secret)
    client.add_share(:comment => options[:msg] + " " +  options[:name] + " " + options[:link] ) 
  end
  
  def twitter_share(account, options)
    Twitter.configure do |config|
      config.consumer_key = OMNIAUTH_CONFIG[:twitter]["key"]
      config.consumer_secret = OMNIAUTH_CONFIG[:twitter]["secret"]
      config.oauth_token = account.provider_token
      config.oauth_token_secret = account.provider_secret
    end
    
    short_url = shorten_url(options[:link])
    msg = options[:msg] + " " +  options[:name] + " " + short_url
    
    begin
      Twitter.update(msg)
    rescue Twitter::Error::Forbidden
      Rails.logger.error " > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > Error : "
      Rails.logger.error "Error >>> Twitter::Error::Forbidden"
      Rails.logger.error " > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > End Error : "
    end
    
  end
  
  def facebook_share(account, options)
    me = FbGraph::User.me(account.provider_token)
    me.feed!(
      :message => options[:msg],
      :picture => options[:picture],
      :link => options[:link],
      :name => options[:name],
      :description => options[:dsc]
    )
  end
  
  def self.user_has_permissions(access_token)
    begin
      permissions = FbGraph::User.me(access_token).permissions
      permissions.include?(:status_update) #&& permissions.include?(:offline_access) 
    rescue
      return false
    end 
  end
  
  def shorten_url(url)
    bitly = Bitly.new('temporary', 'temporary')
    b = bitly.shorten(url)
    return b.short_url
  end
end
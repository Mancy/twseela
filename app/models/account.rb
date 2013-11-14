class Account < ActiveRecord::Base
  belongs_to :user
  
  validates :provider, :presence=>true, :length=>{:maximum=>250}
  validates :uid, :presence=>true, :uniqueness=>{:scope => [:provider], :message=>I18n.t("messages.already_exists")}, :length=>{:maximum=>250}
  validates :provider_token, :presence=>true, :length=>{:maximum=>250}
  
  # default_scope :order => :id
  scope :default_one, where(:default_account => true)
  
  def self.initialize_with_omniauth(auth)
    return Account.find_or_initialize_by_provider_and_uid(auth["provider"], auth["uid"], 
                      Account.basic_attrs(auth))
  end
  
  def url
    return "http://www.facebook.com/#{self.uid}" if self.provider == "facebook"
    return "http://www.linkedin.com/x/profile/#{OMNIAUTH_CONFIG[:linked_in]["key"]}/#{self.uid}" if self.provider == "linked_in"
    return "https://twitter.com/account/redirect_by_id?id=#{self.uid}" if self.provider == "twitter"
  end
  
  def my_image(type="large")
    if self.provider == "facebook"
      "http://graph.facebook.com/#{self.uid}/picture?type=#{type}"
    else
      self.image
    end
  end
  
  #######
  private
  ####### 
  
  def self.basic_attrs(auth)
    return {:provider => auth["provider"],
            :uid => auth["uid"],
            :image => auth["info"]["image"],
            :provider_token => auth["credentials"]["token"],
            :provider_secret => auth["credentials"]["secret"]}
  end
end

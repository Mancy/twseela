# -*- coding: utf-8 -*-
class User < ActiveRecord::Base
  attr_accessor :share_registration, :filter_group
  attr_protected :credits, :created_at, :updated_at, :flags_weight, :rates_weight, :blocked_weight, :last_login, :before_last_login, :reserved_credits, :mileage_sum, :init_credits
  
  before_save :update_last_login
  before_create :update_credits, :set_is_free
  
  belongs_to :city
  
  has_many :accounts, :dependent=>:destroy
  has_many :car_profiles, :dependent=>:destroy
  has_many :transports, :dependent=>:destroy
  has_many :searches, :dependent=>:destroy
  has_many :flags, :dependent=>:destroy
  has_many :blocks, :dependent=>:destroy
  has_many :blocked, :dependent=>:destroy, :foreign_key => "blocked_id", :class_name => "Block"
  has_many :payments, :dependent=>:destroy
  has_many :notification, :dependent=>:destroy
  has_many :notifiables, :as => :notifiable
  has_many :users_requests, :dependent=>:destroy
  
  has_many :transports_requests, :dependent=>:destroy
  has_many :requested_transports, :through => :transports_requests, :source => :transport 
  
  has_many :sent_messages, :class_name => "Message", :foreign_key => :sender_id
  has_many :received_messages, :class_name => "Message", :foreign_key => :recipient_id
  
  has_and_belongs_to_many :groups
  
  validates :accounts, :presence=>true
  validates :car_profiles, :presence=>true, :if => Proc.new{|u| u.has_car == true}
  validates :name, :presence=>true, :length=>{:maximum=>250}
  validates :gender, :friends_type, :presence=>true
  validates_inclusion_of :gender, :in => Gender.gender_ids, :unless => Proc.new{|u| u.gender.blank?}
  validates_inclusion_of :friends_type, :in => FriendsType.type_ids, :unless => Proc.new{|u| u.friends_type.blank?}
  validates :email, :presence=>true, :length=>{:maximum=>250}, :format=>{:with => /^[A-Za-z0-9._]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/ , :unless => Proc.new{|e| e.email.blank?} }
  validates :mobile, :length=>{:maximum=>13, :minimum => 9, :unless => Proc.new{|d| d.mobile.blank?}}, :format=>{:with => /^[0-9٠-٩\s\-\(\)]+$/ , :unless => Proc.new{|d| d.mobile.blank?} }
  # validates :mobile, :presence=>true
  validates :mobile, :uniqueness=>{:unless => Proc.new{|d| d.mobile.blank?}}
  # validates :birthdate, :presence=>true
  validates :email, :uniqueness => {:case_sensitive => false}
  validates :trust_level, :presence=>true
  validates_inclusion_of :trust_level, :in => TrustLevel.trust_levels, :unless => Proc.new{|u| u.trust_level.blank?}
  
  accepts_nested_attributes_for :accounts, :reject_if => proc{|attrs| attrs.all? {|k, v| v.blank?}}
  accepts_nested_attributes_for :car_profiles, :allow_destroy => true, :reject_if => proc{|attrs| attrs.all? {|k, v| v.blank?}}
  
  # default_scope order("created_at desc")
  scope :have_cars, where(:has_car => true)
  scope :have_not_cars, where("has_car is not true")
  scope :transports_notifications, where(:transports_notifications => true)
  scope :new_transports_notifications, where(:new_transports_notifications => true)
  scope :friends_notifications, where(:friends_notifications => true)
  scope :newsletter_notifications, where(:newsletter_notifications => true)
  scope :free_users, where(:is_free => true)
  scope :paid_users, where(:is_free => false)
  
  
  def self.initialize_with_omniauth(auth)
    return User.new(User.basic_attrs(auth))
  end
  
  def set_gender=(gen)
    self.gender = nil
    self.gender = Gender.male if gen && gen.downcase == "male"
    self.gender = Gender.female if gen && gen.downcase == "female"
  end
  
  def gender_name 
    return I18n.t("gender.gender_1", I18n.locale) if self.gender == Gender.male
    return I18n.t("gender.gender_2", I18n.locale)
  end
  
  def default_locale_name
    I18n.t("locales.#{self.default_locale}", I18n.locale)
  end
  
  def trust_level_name
    I18n.t("trust_level.trust_level_#{self.trust_level}", I18n.locale)
  end
  
  def city_name
    self.city.name if self.city
  end
  
  index do
    name
  end
  
  def friends_ids
    frnds_ids = Rails.cache.read("user_#{self.id}_friends_ids")
    
    if frnds_ids.nil?
      ids = Array.new(self.all_friends_ids)
      blks_list_ids = self.blocked_list_ids
      ids.delete_if{|x| blks_list_ids.include?(x)}.push(0)
      
      Rails.cache.write("user_#{self.id}_friends_ids", ids, :expires_in => 1.hours)
      frnds_ids = ids
    end
    
    frnds_ids
  end
  
  def all_friends_ids
    frnds_ids = Rails.cache.read("user_#{self.id}_all_friends_ids")
    
    if frnds_ids.nil?
      start_time = Time.now
      
      ids = []
      
      if self.friends_type == FriendsType.friends || self.friends_type == FriendsType.both
        uids = self.friends_uids
        uids_str = "'0'"
        uids.each do |u|
          uids_str += ", '#{u}'"
        end
        
        ids += Account.select(:user_id).where("uid in (#{uids_str})").collect(&:user_id).push(0)
      end
      
      if self.friends_type == FriendsType.network || self.friends_type == FriendsType.both
        ids += GroupsUser.select(:user_id).where("user_id <> #{self.id}").where(:group_id => self.groups.collect(&:id).push(0)).collect(&:user_id).push(0)
      end
      
      ids = ids.uniq
      
      stop_time = Time.now
      
      Rails.cache.write("user_#{self.id}_all_friends_ids", ids, :expires_in => 1.hours)
      frnds_ids = ids
    end
    
    frnds_ids
  end
  
  def reset_friends_ids_cache
    Rails.cache.delete("user_#{self.id}_friends_ids")
    Rails.cache.delete("user_#{self.id}_all_friends_ids")
  end
  
  def friends_uids
    ids = []
    
    # todo 
    # enhance this method performance by make batch friends_list
    
    self.accounts.each do |account|
      facebook_list = Graphdb.friends_list(account) if account.provider == "facebook"
      ids += facebook_list if facebook_list
      
      twitter_list = Graphdb.friends_list(account) if account.provider == "twitter" && account.user.trust_level > 1
      ids += twitter_list if twitter_list
      
      linked_in_list = Graphdb.friends_list(account) if account.provider == "linked_in"
      ids += linked_in_list if linked_in_list
    end
    ids
  end
  
  def blocked_list_ids
    user_blocked = self.blocked.select(:user_id).collect(&:user_id).push(0)
    user_blocks = self.blocks.select(:blocked_id).collect(&:blocked_id).push(0)
    return (user_blocked + user_blocks).uniq
  end
  
  def self.per_page
    10
  end
  
  def available_credits
    credits - reserved_credits
  end
  
  def mileage_sum_str
    sum_str(self.mileage_sum.to_s)
  end
  
  def friends_sum_str
    sum_str((self.all_friends_ids.size - 1).to_s)
  end
  
  def sum_str(num)
    (6 - num.length).times do
      num = "0" + num
    end
    num
  end
  
  def pages_urls
    #self.accounts.collect(&:url).join(" , ")
    self.accounts.collect{|a| "<a href='#{a.url}' target='_blank'>#{a.provider}</a>"}.join(" , ").html_safe
  end
  
  def is_free?
    self.is_free
  end

  def hash_data
    {:id => self.id,
      :name => self.name,
      :email => self.email,
      :mobile => self.mobile,
      :image_url => self.accounts.default_one.first.image
    }
  end
  
  #######
  private
  ####### 
  def update_last_login
    #todo : check the - 2.hours
    self.before_last_login = (self.last_login_was || self.last_login) - 2.hours if self.before_last_login.blank? || self.last_login_changed?
  end
  
  def update_credits
    self.credits = INIT_CREDITS
    self.init_credits = INIT_CREDITS
  end
  
  def set_is_free
    self.is_free = DEFAULT_IS_FREE
  end
  
  def self.basic_attrs(auth)
    begin
      if auth["provider"] == "linked_in"
        return {:name => auth["info"]["first_name"] + " " + auth["info"]["last_name"]}
      else
        return {:set_gender=>auth["extra"]["user_hash"]["gender"],
                :name => auth["info"]["name"]}
      end
    rescue => e
      puts "  > > > > > e : #{e.message}"
      puts "  > > > > > e : #{e.backtrace}"
    end
  end
end

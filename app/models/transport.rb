# -*- coding: utf-8 -*-
class Transport < ActiveRecord::Base
  attr_accessor :saved_transport, :share_transport, :paths, :repeat_days
  attr_protected :created_at, :updated_at, :flags_count, :rates_count
  
  before_create :set_available_persons
  before_update :update_available_persons
  
  belongs_to :user
  belongs_to :car_profile
  has_one :transports_route, :dependent=>:destroy
  has_many :transports_paths, :dependent=>:destroy
  has_many :transports_requests, :dependent=>:destroy
  has_many :users, :through => :transports_requests
  has_many :flags, :as => :flaggable
  has_many :rates, :as => :rateable
    
  validates :transports_route, :start_time, :car_profile_id, :title, :presence=>true
  validates :title, :length=>{:maximum=>250}, :unless => Proc.new{|u| u.title.blank?}
  validates :return_back_start_time, :presence=>true, :if => Proc.new{|u| u.return_back == true}
  validates :allowed_persons, :length => { :within => 1..7 }
  validates :cost_type, :presence=>true
  validates :gender, :presence=>true
  validates_inclusion_of :cost_type, :in => CostType.cost_type_ids, :unless => Proc.new{|t| t.cost_type.blank?}
  validates_inclusion_of :gender, :in => Gender.gender_ids, :unless => Proc.new{|t| t.gender.blank?}
  validates :cost, :presence=>true
  validate :start_time_after, :validate_points_list
  validate :return_back_start_time_after, :after_start_time, :if => Proc.new{|u| !u.return_back_start_time.blank? && u.return_back == true}
  
  
  # default_scope order("start_time asc")
  scope :next_dates, lambda{
    where("start_time >= '#{Time.now}'")
  }
  scope :running, lambda{
    where("start_time >= '#{Time.now}'")
  }
  scope :previous, lambda{
    where("start_time < '#{Time.now}'")
  }
  scope :rand, lambda {|lim|
    select("*, random() as rand_col").order('rand_col desc').limit(lim)
  }
  scope :has_seats, where("available_persons > 0")
  scope :saved_only, where(:templ_saved => true)
  
  def accessories
    access = I18n.t("accessories.no_accessories")
    access = "" if self.air_cond || self.cassette || self.smoking
    access += I18n.t("accessories.air_cond") + " - " if self.air_cond
    access += I18n.t("accessories.cassette") + " - " if self.cassette
    access += I18n.t("accessories.smoking") + " - " if self.smoking 
    access
  end
  
  def self.per_page
    10
  end
  
  def rates_count
    rates.collect{|r| r.rate}.sum
  end
  
  def rates_avr
    rates.size > 0 && rates_count > 0 ? rates_count / rates.size : 0
  end
  
  def to_param
    "#{Encoder.encode(id)}"
  end
  
  def self.find_encoded(target)
    find(Encoder.decode(target))
  end
  
  def points_list
    if !self.paths.blank?
      x = []
      self.paths.each do |k, v|
        x << {:start_lng => v["start_lng"], :start_lat => v["start_lat"]}
      end
      x
    elsif !self.transports_route.blank?
      x = []
      self.transports_route.path.points.each do |p|
        x << {:start_lng => p.x, :start_lat => p.y}
      end
      x
    else 
      []
    end
  end
  
  def points_list_to_hash
    x = {}
    self.points_list.each_with_index do |point, indx|
      x[indx.to_s] = {"start_lng" => point[:start_lng], "start_lat" => point[:start_lat]}
    end
    x
  end
  
  def self.transports_data(transports)
    transports.collect do |ts|
      {:id => ts.to_param,
        :title => ts.title,
        :start_place => ts.start_place,
        :end_place => ts.end_place,
        :start_time => I18n.l(ts.start_time, :format => :short, :locale => :ar),
        :cost => ts.cost}
    end
  end
  
  def transport_data(transports_requests, current_user)
    transport = self
    transport_request = transports_requests.first if current_user && current_user.id != transport.user_id

    {:id => transport.to_param,
      :title => transport.title,
      :start_place => transport.start_place,
      :end_place => transport.end_place,
      :start_time => I18n.l(transport.start_time, :format => :short, :locale => :ar),
      :return_back_start_time => transport.return_back_start_time ? I18n.l(transport.return_back_start_time, :format => :short, :locale => :ar) : nil,
      :cost => transport.cost,
      :available_persons => transport.available_persons,
      :gender_name => I18n.t("gender.gender_#{transport.gender}", :locale => :ar),
      :flags_count => transport.flags_count,
      :rates_count => transport.rates_count,
      :rate => transport.rates_avr,
      :is_owner => current_user && current_user.id == transport.user_id,
      :has_accepted_request => transport_request && transport_request.status == Status.accepted,
      :owner => transport.user.hash_data,
      :car => transport.car_profile ? transport.car_profile.hash_data : nil,
      :transports_requests => transports_requests.collect(&:hash_data),
      :points_list => transport.points_list
     }
  end
  
  #######
  private 
  #######
  
  def set_available_persons
    self.available_persons = allowed_persons
  end
  def update_available_persons
    self.available_persons = allowed_persons if self.allowed_persons_changed?
  end
  def validate_points_list
    self.errors.add(:transports_paths, I18n.t("errors.transports_paths")) if self.points_list.size < 2
  end
  def start_time_after
    validate_time_after(:start_time) if !self.start_time.blank? && self.start_time <= Time.now
  end
  def return_back_start_time_after
    validate_time_after(:return_back_start_time) if !self.return_back_start_time.blank? && self.return_back_start_time <= Time.now
  end
  def after_start_time
    self.errors.add(:return_back_start_time, I18n.t("errors.after_start_time"))  if !self.start_time.blank? && !self.return_back_start_time.blank? && self.return_back_start_time <= self.start_time
  end
  def validate_time_after(attr)
    self.errors.add(attr, I18n.t("errors.start_time_after"))
  end
end

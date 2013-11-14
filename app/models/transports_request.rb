class TransportsRequest < ActiveRecord::Base
  attr_accessor :notify_type
  attr_protected :money_back, :created_at, :updated_at, :flags_count, :rates_count
  
  belongs_to :user
  belongs_to :transport
  has_many :flags, :as => :flaggable
  has_many :rates, :as => :rateable
  
  validates :status, :presence=>true
  validates :for_persons, :presence=>true
  
  validates :requester_cost, :presence=>true, :if => Proc.new{|tr| tr.status == Status.requested}
  validates :requester_meet_place, :presence=>true, :if => Proc.new{|tr| tr.status == Status.requested}
  # validates :requester_meet_lng, :presence=>true, :if => Proc.new{|tr| tr.status == Status.requested}
  # validates :requester_meet_lat, :presence=>true, :if => Proc.new{|tr| tr.status == Status.requested}
  
  validates :requester_return_back_meet_place, :presence=>true, :if => Proc.new{|tr| tr.status == Status.requested && tr.requester_return_back == true}
  # validates :requester_return_back_meet_lng, :presence=>true, :if => Proc.new{|tr| tr.status == Status.requested && tr.requester_return_back == true}
  # validates :requester_return_back_meet_lat, :presence=>true, :if => Proc.new{|tr| tr.status == Status.requested && tr.requester_return_back == true}
  
  validates :transporter_message, :presence=>true, :if => Proc.new{|tr| tr.status == Status.rejected}
  validates :transporter_meet_time, :presence=>true, :if => Proc.new{|tr| tr.status == Status.accepted}
  validates :transporter_return_back_meet_time, :presence=>true, :if => Proc.new{|tr| tr.status == Status.accepted && tr.requester_return_back == true }
  
  validates_each :requester_cost do |record, attr, value|
    record.errors.add(attr, I18n.t("errors.less_than_required")) if record.transport && record.transport.cost_type == CostType.paid && !value.blank? &&  value < (record.transport.cost * 0.30)
  end
  
  default_scope order("created_at desc")
  scope :requested, where(:status => Status.requested)
  scope :accepted, where(:status => Status.accepted)
  
  def total_cost
    return 0 if self.transport.cost <= 0
    calc_cost = self.requester_cost.to_f * self.for_persons.to_f
    calc_cost = calc_cost * 2.0 if self.requester_return_back == true
    calc_cost
  end
  
  def hash_data
    {:id => self.id, 
      :requester => self.user.hash_data, 
      :for_persons => self.for_persons, 
      :status => self.status, 
      :requester_message => self.requester_message, 
      :requester_meet_place => self.requester_meet_place, 
      :requester_return_back => self.requester_return_back, 
      :requester_return_back_meet_place => self.requester_return_back_meet_place, 
      :requester_cost => self.requester_cost, 
      :transporter_message => self.transporter_message, 
      :transporter_meet_time => self.transporter_meet_time ? I18n.l(self.transporter_meet_time, :format => :short, :locale => :ar) : nil ,
      :transporter_return_back_meet_time => self.transporter_return_back_meet_time ? I18n.l(self.transporter_return_back_meet_time, :format => :short, :locale => :ar) : nil,
      :requester_meet_lng => self.requester_meet_lng,
      :requester_meet_lat => self.requester_meet_lat
    }
  end 
end

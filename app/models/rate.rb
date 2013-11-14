class Rate < ActiveRecord::Base
  belongs_to :user
  belongs_to :rateable, :polymorphic => true, :counter_cache => true
  
  validates :rateable_id, :presence=>true
  validates :rateable_type, :presence=>true
  validates :user_id, :presence=>true
  validates :rate, :presence=>true
  validates_inclusion_of :rate, :in => 0..5, :unless => Proc.new{|r| r.rate.blank?}
  
  after_save :update_user_rates_weight
  before_destroy :decrement_user_rates_weight
  
  #######
  private
  #######
  
  def update_user_rates_weight
    self.rateable.user.update_attribute(:rates_weight, self.rateable.user.rates_weight.to_i + (self.rate.to_i - self.rate_was.to_i)) if self.rate_changed?
    self.destroy if self.rate_changed? && self.rate <= 0
  end
  
  def decrement_user_rates_weight
    self.rateable.user.update_attribute(:rates_weight, self.rateable.user.rates_weight.to_i - self.rate)
  end
end
class Flag < ActiveRecord::Base
  belongs_to :user
  belongs_to :flaggable, :polymorphic => true, :counter_cache => true
  
  validates :flaggable_id, :presence=>true
  validates :flaggable_type, :presence=>true
  validates :user_id, :presence=>true
  validates :flag, :presence=>true
  validates :flag, :length => { :maximum => 250 }, :unless => Proc.new{|f| f.flag.blank? }
  validates :comment, :length => { :maximum => 250 }
  validates :level, :presence=>true
  validates_inclusion_of :level, :in => TrustLevel.trust_levels, :unless => Proc.new{|f| f.level.blank?}
  
  after_create :increment_user_flags_weight
  before_destroy :decrement_user_flags_weight
  
  #######
  private
  #######
  
  def increment_user_flags_weight
    self.flaggable.user.update_attribute(:flags_weight, self.flaggable.user.flags_weight.to_i + self.level)
  end
  
  def decrement_user_flags_weight
    self.flaggable.user.update_attribute(:flags_weight, self.flaggable.user.flags_weight.to_i - self.level)
  end
end
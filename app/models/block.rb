class Block < ActiveRecord::Base
  belongs_to :user
  belongs_to :blocked, :class_name => "User", :counter_cache => :blocked_weight
  
  scope :for_blocked, lambda{|blocked_id|
    where(:blocked_id => blocked_id).limit(1)
  }
  
  def self.per_page
    10
  end
end
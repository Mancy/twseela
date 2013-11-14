class UsersRequest < ActiveRecord::Base
  belongs_to :user
  belongs_to :requester, :class_name => "User"
  belongs_to :requestable, :polymorphic => true
  validates :details, :presence=>true, :length=>{:maximum=>250}
  default_scope order("created_at desc")
  
  def self.per_page
    20
  end
    
  def url
    if requestable_type == "Transport"
      return "/transports/#{self.requestable.to_param}"
    end
  end
end

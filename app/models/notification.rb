class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :notifiable, :polymorphic => true
  validates :notification, :presence=>true, :length=>{:maximum=>250}
  default_scope order("created_at desc")
  
  def self.per_page
    20
  end
    
  def url
    if notifiable_type == "User"
      return "/users/#{self.notifiable_id}"
    elsif notifiable_type == "Transport"
      return "/transports/#{self.notifiable.to_param}"
    end
  end
end
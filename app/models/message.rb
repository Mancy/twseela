class Message < ActiveRecord::Base
  belongs_to :sender, :class_name => 'User', :foreign_key => "sender_id"
  belongs_to :recipient, :class_name => 'User', :foreign_key => "recipient_id"
  
  validates :subject, :body, :presence=>true
  validates :subject, :length=>{:maximum=>250}, :unless => Proc.new{|m| m.subject.blank?}
  validates :body, :length=>{:maximum=>1024}, :unless => Proc.new{|m| m.body.blank?}
  
  scope :not_checked, where(:checked => false)
  
  def self.per_page
    20
  end
end

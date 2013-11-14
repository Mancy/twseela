class Feedback
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :title, :body, :email
  validates :title, :presence=>true, :length=>{:maximum=>250}
  validates :body, :presence=>true, :length=>{:maximum=>1024}
  validates :email, :presence=>true, :format=>{:with => /^[A-Za-z0-9._]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/ , :unless => Proc.new{|e| e.email.blank?} }
  
  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end
  
  def persisted?
    false
  end

  def save
    if valid?
      Mailer.feedback_email(self.title,self.body,self.email).deliver
      return true
    else
      return false
    end
  end
end
class Newsletter < ActiveRecord::Base
  # include ActiveModel::Validations
  # include ActiveModel::Conversion
  # extend ActiveModel::Naming
  # 
  attr_accessor :emails, :has_cars
  validates :title, :presence=>true, :length=>{:maximum=>100}
  validates :body, :presence=>true, :length=>{:maximum=>1024}
  validates :emails, :presence=>true #, :format=>{:with => /^[A-Za-z0-9._]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/ , :unless => Proc.new{|e| e.email.blank?} }
  
  # default_scope order("created_at desc")
  
  def send_mail
    self.emails.each do |email|
      Mailer.newsletter_email(self.id, email).deliver
    end
  end
  
  # 
  # def self.quoted_table_name
  #   "newsletter"
  # end
  # 
  # def self.order
  #   "asc"
  # end
  # 
  # def initialize(attributes = {})
  #   attributes.each do |name, value|
  #     send("#{name}=", value)
  #   end
  # end
  # 
  # def persisted?
  #   false
  # end
  # 
  # def save
  #   # if valid?
  #   #   Mailer.feedback_email(self.title,self.body,self.email).deliver
  #   #   return true
  #   # else
  #   #   return false
  #   # end
  # end
end
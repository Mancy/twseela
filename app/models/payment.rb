class Payment < ActiveRecord::Base
  belongs_to :user
  
  validates :user, :amount, :payment_type, :status_id, :presence=>true
  validates_inclusion_of :payment_type, :in => PaymentType.payment_types_ids, :unless => Proc.new{|p| p.payment_type.blank?}
  validates :amount, :numericality => {:greater_than => 1}, :unless => Proc.new{|p| p.amount.blank?}
end
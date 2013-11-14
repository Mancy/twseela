class PaymentType
  @@payment_types = {:cashu => 1}
  
  def self.payment_types_ids
    @@payment_types.values
  end
  
  def self.cashu
    @@payment_types[:cashu]
  end
end
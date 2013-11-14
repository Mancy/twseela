class MoneyTransactionType
  @@money_transaction_types = {:init_val => 1, 
                               :pay_for_ride => 2, 
                               :collect_for_ride => 3, 
                               :cancel_pay_for_ride => 4, 
                               :cancel_collect_for_ride => 5, 
                               :twseela_commission => 6, 
                               :recharge => 7}
  
  def self.money_transaction_types_ids
    @@money_transaction_types.values
  end
  
  def self.init_val
    @@money_transaction_types[:init_val]
  end
  
  def self.pay_for_ride
    @@money_transaction_types[:pay_for_ride]
  end
  
  def self.collect_for_ride
    @@money_transaction_types[:collect_for_ride]
  end
  
  def self.cancel_pay_for_ride
    @@money_transaction_types[:cancel_pay_for_ride]
  end
  
  def self.cancel_collect_for_ride
    @@money_transaction_types[:cancel_collect_for_ride]
  end
  
  def self.twseela_commission
    @@money_transaction_types[:twseela_commission]
  end
  
  def self.recharge
    @@money_transaction_types[:recharge]
  end
end
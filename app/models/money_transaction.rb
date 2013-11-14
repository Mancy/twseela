class MoneyTransaction < ActiveRecord::Base
  belongs_to :user
  belongs_to :transactable, :polymorphic => true
  
  validates :money_transaction_type_id, :presence=>true
  validates :credit, :presence=>true, :if => Proc.new{|mt| mt.debit.blank? }
  validates :debit, :presence=>true, :if => Proc.new{|mt| mt.credit.blank? }
  
  def self.add_transaction(usr, type_id, amount, for_obj=nil, detail=nil)
    if type_id == MoneyTransactionType.init_val
      crdt = amount
      dbt = 0
    elsif type_id == MoneyTransactionType.pay_for_ride
      crdt = 0
      dbt = amount
    elsif type_id == MoneyTransactionType.collect_for_ride
      crdt = amount
      dbt = 0
    elsif type_id == MoneyTransactionType.cancel_pay_for_ride
      crdt = amount
      dbt = 0
    elsif type_id == MoneyTransactionType.cancel_collect_for_ride
      crdt = 0
      dbt = amount
    elsif type_id == MoneyTransactionType.twseela_commission
      crdt = amount
      dbt = 0
    elsif type_id == MoneyTransactionType.recharge
      crdt = amount
      dbt = 0
    end
    
    MoneyTransaction.create(:user => usr, 
                            :details => detail, 
                            :transactable => for_obj, 
                            :money_transaction_type_id => type_id, 
                            :credit => crdt,
                            :debit => dbt)
    
  end
  
end
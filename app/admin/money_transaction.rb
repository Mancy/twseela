ActiveAdmin.register MoneyTransaction do 
  filter :id
  filter :user_id, :as => :numeric
  filter :created_at
  
  index do
    column :id
    column :user
    column :credit
    column :debit
    column :transactable
    column :money_transaction_type_id
    
    default_actions
  end
end
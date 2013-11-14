ActiveAdmin.register Payment do 
  filter :id
  filter :user_id, :as => :numeric
  filter :payment_type, :as => :select, :collection => proc { PaymentType.payment_types_ids }
  filter :status_id, :as => :select, :collection => proc { [1, 2] }
  filter :transaction_id
  filter :token
  filter :created_at
  
  index do
    column :id
    column :user
    column :amount
    column :status_id
    column :transaction_id
    
    default_actions
  end
end
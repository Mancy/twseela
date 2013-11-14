class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer         :user_id
      t.float           :amount, :default => 0
      t.integer         :payment_type
      t.integer         :payment_method
      t.timestamps
    end
  end
end
class UpdatePaymentsTable < ActiveRecord::Migration
  def up
    remove_column :payments, :payment_method
    add_column :payments, :status_id, :integer
    add_column :payments, :token, :string
    add_column :payments, :session_id, :string
  end

  def down
    add_column :payments, :payment_method, :integer
    remove_column :payments, :status_id
    remove_column :payments, :token
    remove_column :payments, :session_id
  end
end
class AddMoreColumnsToMoneyTransactionsTable < ActiveRecord::Migration
  def change
    add_column :money_transactions, :transactable_id, :integer
    add_column :money_transactions, :transactable_type, :string
    add_column :money_transactions, :money_transaction_type_id, :integer
  end
end

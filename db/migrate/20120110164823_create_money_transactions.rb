class CreateMoneyTransactions < ActiveRecord::Migration
  def change
    create_table :money_transactions do |t|
      t.integer           :user_id
      t.float             :credit
      t.float             :debit
      t.string            :details
      t.timestamps
    end
  end
end
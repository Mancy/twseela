class AddNodeIdToAccountsTable < ActiveRecord::Migration
  def change
    add_column :accounts, :node_id, :integer
  end
end

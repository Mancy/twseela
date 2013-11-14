class AddBlockedWeightToUsersTable < ActiveRecord::Migration
  def change
    add_column :users, :blocked_weight, :integer, :default => 0
  end
end

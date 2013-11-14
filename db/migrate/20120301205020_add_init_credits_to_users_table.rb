class AddInitCreditsToUsersTable < ActiveRecord::Migration
  def change
    add_column :users, :init_credits, :float, :default => 0
  end
end
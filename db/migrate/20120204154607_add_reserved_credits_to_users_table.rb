class AddReservedCreditsToUsersTable < ActiveRecord::Migration
  def up
    add_column :users, :reserved_credits, :float, :default => 0
    
    User.reset_column_information
    User.update_all "reserved_credits = 0"
  end
  
  def down
    remove_column :users, :reserved_credits, :float, :default => 0
  end
end

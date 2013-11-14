class AddFriendsTypeToUsersTable < ActiveRecord::Migration
  def change
    add_column :users, :friends_type, :integer, :default => 1
  end
end

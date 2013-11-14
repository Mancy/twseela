class AddLastFriendsCountToUsersTable < ActiveRecord::Migration
  def change
    add_column :users, :last_friends_count, :integer, :default => 0
  end
end

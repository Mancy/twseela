class AddNotificationsFieldsToUsersTable < ActiveRecord::Migration
  def change
    add_column :users, :transports_notifications, :boolean, :default => true
    add_column :users, :new_transports_notifications, :boolean, :default => true
    add_column :users, :friends_notifications, :boolean, :default => true
  end
end
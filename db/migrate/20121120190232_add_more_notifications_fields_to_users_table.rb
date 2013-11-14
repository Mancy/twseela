class AddMoreNotificationsFieldsToUsersTable < ActiveRecord::Migration
  def change
    add_column :users, :newsletter_notifications, :boolean, :default => true
  end
end

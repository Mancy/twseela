class AddIsFreeToUsersAndGroups < ActiveRecord::Migration
  def change
    add_column :users, :is_free, :boolean, :default => false
    add_column :groups, :is_free, :boolean, :default => false
  end
end

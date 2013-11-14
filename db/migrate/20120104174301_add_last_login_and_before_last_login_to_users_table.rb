class AddLastLoginAndBeforeLastLoginToUsersTable < ActiveRecord::Migration
  def change
    add_column :users, :last_login, :datetime
    add_column :users, :before_last_login, :datetime
  end
end

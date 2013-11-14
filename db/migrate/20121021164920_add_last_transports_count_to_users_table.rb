class AddLastTransportsCountToUsersTable < ActiveRecord::Migration
  def up
    add_column :users, :last_transports_count, :integer, :default => 0
    
    User.reset_column_information
    
    User.have_cars.each do |user|
      user.update_attribute(:last_transports_count, user.transports.count)
    end
  end
  
  def down
    remove_column :users, :last_transports_count
  end
end

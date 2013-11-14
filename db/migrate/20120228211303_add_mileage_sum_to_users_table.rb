class AddMileageSumToUsersTable < ActiveRecord::Migration
  def change
    add_column :users, :mileage_sum, :integer, :default => 0
  end
end

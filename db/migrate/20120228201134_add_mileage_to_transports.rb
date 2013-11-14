class AddMileageToTransports < ActiveRecord::Migration
  def up
    add_column :transports, :mileage, :integer, :default => 0
    remove_column :transports, :milage
  end
  def down
    remove_column :transports, :mileage
    add_column :transports, :milage, :integer, :default => 0
  end
end
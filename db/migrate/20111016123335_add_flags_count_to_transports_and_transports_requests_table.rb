class AddFlagsCountToTransportsAndTransportsRequestsTable < ActiveRecord::Migration
  def change
    add_column :transports, :flags_count, :integer, :default => 0
    add_column :transports_requests, :flags_count, :integer, :default => 0
    add_column :users, :flags_weight, :integer, :default => 0
    add_column :transports, :car_profile_id, :integer
  end
end
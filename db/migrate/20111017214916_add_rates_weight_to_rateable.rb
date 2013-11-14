class AddRatesWeightToRateable < ActiveRecord::Migration
  def change
    add_column :transports, :rates_count, :integer, :default => 0
    add_column :transports_requests, :rates_count, :integer, :default => 0
    add_column :users, :rates_weight, :integer, :default => 0
  end
end
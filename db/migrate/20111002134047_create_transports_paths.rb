class CreateTransportsPaths < ActiveRecord::Migration
  def change
    create_table :transports_paths do |t|
      t.string    :start_place
      t.float     :start_lng
      t.float     :start_lat
      t.string    :road_path
      t.boolean   :return_back, :default => false
      t.integer   :transport_id

      t.timestamps
    end
  end
end

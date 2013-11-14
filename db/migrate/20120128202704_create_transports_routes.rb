class CreateTransportsRoutes < GeoDb
  def up
    create_table :transports_routes do |t|
      t.integer             :transport_id
      t.datetime            :transport_start_time
      t.line_string         :path, :srid => 4326
      
      t.timestamps
    end
  end
  def down
    drop_table :transports_routes
  end
end
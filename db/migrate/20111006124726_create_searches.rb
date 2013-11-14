class CreateSearches < ActiveRecord::Migration
  def change
    create_table :searches do |t|
      t.datetime  :start_time_from
      t.datetime  :start_time_to
      t.integer   :cost_type
      t.boolean   :air_cond
      t.boolean   :cassette
      t.boolean   :smoking
      t.boolean   :return_back
      
      t.string    :start_place
      t.float     :start_lng
      t.float     :start_lat
      
      t.string    :road_path
      
      t.string    :search_name
      t.integer   :user_id
      
      t.timestamps
    end
  end
end

class CreateSearchesPaths < ActiveRecord::Migration
  def change
    create_table :searches_paths do |t|
      t.string    :start_place
      t.float     :start_lng
      t.float     :start_lat
      t.integer   :search_id
      
      t.timestamps
    end
  end
end

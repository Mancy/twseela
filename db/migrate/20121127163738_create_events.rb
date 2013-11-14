class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string      :title
      t.datetime    :start_time
      t.float       :start_lng
      t.float       :start_lat
      t.string      :page_url
      
      t.timestamps
    end
  end
end

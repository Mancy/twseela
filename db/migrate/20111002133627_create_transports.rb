class CreateTransports < ActiveRecord::Migration
  def change
    create_table :transports do |t|
      t.datetime  :start_time
      t.datetime  :return_back_start_time
      t.integer   :allowed_persons, :default => 1
      t.integer   :available_persons, :default => 1
      t.integer   :cost_type
      t.float     :cost, :default => 0
      t.boolean   :air_cond, :default => false
      t.boolean   :cassette, :default => false
      t.boolean   :smoking, :default => false
      t.boolean   :return_back, :default => false
      t.integer   :user_id
      t.integer   :milage
      t.integer   :gender
      
      t.timestamps
    end
  end
end
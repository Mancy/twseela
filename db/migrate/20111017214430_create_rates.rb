class CreateRates < ActiveRecord::Migration
  def change
    create_table :rates do |t|
      t.integer       :rate
      t.integer       :rateable_id
      t.string        :rateable_type
      t.integer       :user_id

      t.timestamps
    end
  end
end

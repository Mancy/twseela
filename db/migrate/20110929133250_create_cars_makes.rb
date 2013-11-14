class CreateCarsMakes < ActiveRecord::Migration
  def change
    create_table :cars_makes do |t|
      t.string        :name_en
      t.string        :name_ar
      t.timestamps
    end
  end
end

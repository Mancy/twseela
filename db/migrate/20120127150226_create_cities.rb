class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.string        :name_ar
      t.string        :name_en
      t.float         :lng
      t.float         :lat
      t.timestamps
    end
  end
end
class CreateCarProfiles < ActiveRecord::Migration
  def change
    create_table :car_profiles do |t|
      t.string      :number
      t.string      :color
      t.date        :make_date
      t.string      :model_name
      t.integer     :cars_make_id
      t.integer     :user_id
      t.integer     :gasoline_type_id
      
      t.timestamps
    end
  end
end

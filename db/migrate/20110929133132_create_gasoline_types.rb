class CreateGasolineTypes < ActiveRecord::Migration
  def change
    create_table :gasoline_types do |t|
      t.string :name_ar
      t.string :name_en
      t.float :price, :default => 0
      
      t.timestamps
    end
  end
end

class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string    :name
      t.integer   :gender
      t.string    :email
      t.string    :mobile
      t.boolean   :has_car
      t.integer   :trust_level, :default => 1
      t.date      :birthdate
      t.float     :credits, :default => 0
      t.string    :default_locale, :default => "ar"

      t.timestamps
    end
  end
end
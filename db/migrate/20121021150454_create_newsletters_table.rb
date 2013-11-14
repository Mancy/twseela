class CreateNewslettersTable < ActiveRecord::Migration
  def up
    create_table :newsletters do |t|
      t.string :title
      t.text :body
      t.timestamps
    end
  end

  def down
    drop_table :newsletters
  end
end

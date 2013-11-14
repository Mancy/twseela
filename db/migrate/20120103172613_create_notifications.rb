class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :user_id
      t.integer :notifiable_id
      t.string :notifiable_type
      t.string :notification
      
      t.timestamps
    end
  end
end

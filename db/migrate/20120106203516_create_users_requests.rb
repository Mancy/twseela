class CreateUsersRequests < ActiveRecord::Migration
  def change
    create_table :users_requests do |t|
      t.integer :user_id
      t.integer :requester_id
      t.integer :requestable_id
      t.string :requestable_type
      t.string :details
      
      t.timestamps
    end
  end
end

class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer       :sender_id
      t.integer       :recipient_id
      t.string        :subject
      t.string        :body, :limit=>1024
      t.boolean       :checked, :default => false
      
      t.timestamps
    end
  end
end

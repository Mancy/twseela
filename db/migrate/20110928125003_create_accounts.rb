class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string    :provider
      t.string    :uid
      t.string    :image
      t.string    :provider_token
      t.string    :provider_secret
      t.integer   :user_id
      t.boolean   :default_account, :default => false
      t.datetime  :last_update
      
      t.timestamps
    end
  end
end

class CreateTransportsRequests < ActiveRecord::Migration
  def change
    create_table :transports_requests do |t|
      t.integer     :user_id
      t.integer     :transport_id
      
      t.integer     :for_persons
      t.integer     :status
      t.integer     :money_back
      
      t.string      :requester_message
      t.string      :requester_meet_place
      t.float       :requester_meet_lng
      t.float       :requester_meet_lat
      t.boolean     :requester_return_back, :default => false
      t.string      :requester_return_back_meet_place
      t.float       :requester_return_back_meet_lng
      t.float       :requester_return_back_meet_lat
      t.integer     :requester_notify_type
      t.float       :requester_cost
      
      
      t.string      :transporter_message
      t.datetime    :transporter_meet_time
      t.datetime    :transporter_return_back_meet_time
      t.integer     :transporter_notify_type
      
      t.timestamps
    end
  end
end
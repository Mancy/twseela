namespace :sent_requests do
  task :reject_old_requests => :environment do
    puts "> > > Start . . . "
    puts ""
    
    TransportsRequest.where(:status => 1).each_with_index do |transport_request, indx|
      if transport_request.transport.start_time < Time.now
        transport_request.update_attribute(:status, Status.rejected)
        transport_request.user.update_attribute(:reserved_credits, transport_request.user.reserved_credits.to_f - transport_request.total_cost)
        UsersRequest.create(:user_id => transport_request.user_id, :requester_id => transport_request.transport.user_id, :requestable => transport_request.transport, :details => "users_requests.system_reject_request")
        TransportMailer.system_reject_transport_request(transport_request.user_id, transport_request.id).deliver
      end
      
      print('.') if (indx % 10) == 0
    end
    
    puts "> > > Done"
  end
end
#to run it every week
namespace :friends_tasks do
  task :friends_counts => :environment do
    puts "> > > Start . . . : #{Time.now.to_s}"
    puts ""
    sent_to_count = 0
    sent_errors = 0 
    User.friends_notifications.each do |user|
      sent_to_count += 1
      begin
        if user.friends_ids.size == user.last_friends_count || user.last_friends_count.to_i < 1
          latest_friends = User.order("created_at desc").where("id <> #{user.id}").where("id in (#{user.friends_ids.join(',')})").limit(14)
          SyncUserMailer.friends_counts(user, user.friends_ids.size, latest_friends).deliver
        else
          user.last_friends_count = user.friends_ids.size
          user.save
          
          latest_friends = User.order("created_at desc").where("id <> #{user.id}").where("id in (#{user.friends_ids.join(',')})").limit(14)
          SyncUserMailer.new_friends_counts(user, user.last_friends_count, latest_friends).deliver
        end
      rescue => e
        sent_errors += 1
        puts " Error > > > > > user : #{user.id}"
        puts " Error > > > > > e : #{e.message}"
        # puts " Error > > > > > e : #{e.backtrace}"
      end
      print "."
    end
    puts ""
    puts "> > > Done : Sent to Count : #{sent_to_count} : sent_errors : #{sent_errors}"
  end
  
  
  task :transports_counts => :environment do
    puts "> > > Start . . . : #{Time.now.to_s}"
    puts ""
    sent_to_count = 0 
    sent_errors = 0
    User.have_cars.transports_notifications.each do |user|
      begin
        if user.transports.count == user.last_transports_count
          sent_to_count += 1
          SyncUserMailer.transports_counts(user).deliver
        else
          user.last_transports_count = user.transports.count
          user.save
        end
      rescue => e
        sent_errors += 1
        puts " Error > > > > > user : #{user.id}"
        puts " Error > > > > > e : #{e.message}"
        # puts " Error > > > > > e : #{e.backtrace}"
      end
      
      print "."
    end
    puts ""
    puts "> > > Done : Sent to Count : #{sent_to_count} : sent_errors : #{sent_errors}"
  end
end
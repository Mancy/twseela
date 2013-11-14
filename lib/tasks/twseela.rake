namespace :twseela do
  task :init_val => :environment do
    puts "> > > Start . . . "
    puts ""
    
    #User.paid_users.each_with_index do |user, indx|
    User.where("id not in (#{MoneyTransaction.select(:user_id).collect(&:user_id).join(', ')})").each_with_index do |user, indx|
      begin
        User.transaction do
          user.is_free = DEFAULT_IS_FREE
          user.credits = INIT_CREDITS
          user.init_credits = INIT_CREDITS
          user.reserved_credits = 0
          
          MoneyTransaction.add_transaction(user, MoneyTransactionType.init_val, INIT_CREDITS)
          user.save
        end
      rescue => e
        puts "Error >>> " + e.message
        puts e.backtrace.join("\n")
      end
      print('.') if (indx % 10) == 0
    end
    
    puts "> > > Done"
  end
end
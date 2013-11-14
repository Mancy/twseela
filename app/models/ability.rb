class Ability
  include CanCan::Ability
  
  def initialize(user)
    can [:get_current_user, :check_current_user], User
    can :get_token, Transport
    can [:new, :get_token], Search
    
    if user
      can [:index], User
      can [:show], User do |u|
        u.id == user.id || user.friends_ids.include?(u.id)
      end 
      can [:edit, :update, :merge_accounts, :update_default_account, :dashboard, :invite_friends], User do |u|
        u.id == user.id
      end
      can [:index, :transports_requests], Transport
      can [:new], Transport
      can [:create], Transport do |t|
        user.has_car
      end
      can [:edit, :update], Transport do |t|
        t.user_id == user.id && t.transports_requests.size == 0
      end
      can [:share], Transport do |t|
        t.user_id == user.id
      end
      can [:delete], Transport do |t|
        t.user_id == user.id && t.transports_requests.size == 0
      end
      can [:repeat], Transport do |t|
        t.user_id == user.id && (t.start_time <= Time.now || t.start_time.to_date == Date.today)
      end
      can :show, Transport do |t|
        t.user_id == user.id || user.friends_ids.include?(t.user_id)
      end 
      can :detail, Transport do |t|
        tr = user.transports_requests.where(:transport_id=>t.id).first
        t.user_id == user.id || tr
      end
      can [:new, :create], TransportsRequest do |transports_request|
        tr = user.transports_requests.where(:transport_id => transports_request.transport_id).first
        user.id != transports_request.transport.user_id && !tr && transports_request.transport.start_time >= Time.now && transports_request.transport.available_persons > 0 #&& user.available_credits >= transports_request.transport.cost 
      end
      can [:reject_request], TransportsRequest do |transports_request|
        #tr = user.transports_requests.where(:transport_id => transports_request.transport_id).first
        transports_request.transport.user_id == user.id && transports_request.transport.start_time >= Time.now #|| tr # i commited this to allow the transporter update status at any time #&& transports_request.status == Status.requested
      end
      can [:transports_response, :accept_request], TransportsRequest do |transports_request|
        #tr = user.transports_requests.where(:transport_id => transports_request.transport_id).first
        transports_request.transport.user_id == user.id && transports_request.transport.start_time >= Time.now && transports_request.transport.available_persons > 0 
      end
      can [:edit, :update], TransportsRequest do |transports_request|
        transports_request.user_id == user.id 
      end
      can [:cancel_request], TransportsRequest do |transports_request|
        transports_request.user_id == user.id && transports_request.transport.start_time - 2.hours >= Time.now
      end
      can :delete, TransportsRequest do |transports_request|
        transports_request.user_id == user.id && transports_request.status == Status.requested
      end
      can [:index, :my_searches, :results], Search
      can [:delete, :show, :edit, :update], Search do |search|
        user.id == search.user_id
      end
      can [:new, :create], Flag do |flag|
        flags = Flag.where(:flaggable_type => flag.flaggable_type, :flaggable_id => flag.flaggable_id, :user_id => user.id)
        flag.flaggable && flag.flaggable.user_id != user.id && flags.size == 0
      end
      can [:delete], Flag do |flag|
        flag.user_id == user.id
      end
      can [:new, :create], Rate do |rate|
        #rates = Rate.where(:rateable_type => rate.rateable_type, :rateable_id => rate.rateable_id, :user_id => user.id)
        #&& rates.size == 0
        rate.rateable && rate.rateable.user_id != user.id
      end
      can [:edit, :update], Rate do |rate|
        rate.user_id == user.id
      end
      can [:new], Block do |b|
        b.user_id == user.id && b.blocked_id != user.id && user.blocks.for_blocked(b.blocked_id).size == 0
      end
      can [:index], Block do |b|
        b.user_id == user.id
      end
      can [:delete], Block do |b|
        b.user_id == user.id
      end
      can [:index, :new, :create, :cashu_approved, :cashu_sorry], Payment
      can [:confirm, :destroy], Payment do |p|
        p.user_id == user.id
      end
      can [:index], Notification do |notification|
        notification.user_id.blank? || notification.user_id == user.id
      end
      can [:index], UsersRequest do |users_request|
        users_request.user_id.blank? || users_request.user_id == user.id
      end
      can [:new, :create], Message do |message|
        message.sender_id == user.id && message.recipient_id != user.id 
      end
      can [:index, :sent], Message do |message|
        message.sender_id.blank? || message.sender_id == user.id
      end
      can [:show], Message do |message|
        message.sender_id == user.id || message.recipient_id == user.id
      end
      can [:new, :create], GroupsUser do |groups_user|
        user.friends_type != FriendsType.friends && user.groups.size > 0
      end
    else
      can [:new, :create], User
      can [:new, :show], Transport
      can [:cashu_approved, :cashu_sorry], Payment
    end
  end
end

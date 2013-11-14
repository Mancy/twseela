ActiveAdmin.register User do 
    filter :id
    filter :name
    filter :email
    filter :mobile
    filter :credits
    filter :has_car, :as => :select, :collection => proc { ["true", "false"] }
  
  show do |ad|
    attributes_table do
      row :pages_urls
    end
    
    attributes_table do
      row :id
      row :name
      row :email
      row :mobile
      row :birthdate
    end
    
    attributes_table do
      row :default_locale
      row :has_car
      row :trust_level
    end
    
    attributes_table do
      row :credits
      row :init_credits
      row :reserved_credits
    end
    
    attributes_table do
      row :last_friends_count
      row :last_transports_count
    end
    
    attributes_table do
      row :flags_weight
      row :rates_weight
      row :blocked_weight
      row :mileage_sum
    end
    
    attributes_table do
      row :transports_notifications
      row :new_transports_notifications
      row :friends_notifications
      row :newsletter_notifications
    end
    
    attributes_table do
      row :last_login
      row :before_last_login
      row :created_at
      row :updated_at
    end
  end
  
  index do
    column :id
    column :name
    column :email
    column :mobile
    column :has_car
    column :credits
    
    default_actions
  end
  
  form do |f|
    f.inputs "User Details" do
      f.input :name
      f.input :email
      f.input :mobile
    end
    
    f.inputs "User Credits" do
      f.input :credits
      f.input :init_credits
      f.input :reserved_credits
    end
    
    f.inputs "User Settings" do
      f.input :default_locale
      f.input :trust_level
    end
    
    f.inputs "Notifications" do
      f.input :transports_notifications
      f.input :new_transports_notifications
      f.input :friends_notifications
      f.input :newsletter_notifications
    end
    
    f.buttons
  end
end
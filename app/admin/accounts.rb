ActiveAdmin.register Account do
    actions :index, :show, :edit, :update
    
    filter :provider
    filter :uid
    filter :user_id, :as => :numeric
      
    show do |ac|
      attributes_table do
        row :image do
          image_tag(ac.image)
        end
        row :url do
          link_to ac.provider, ac.url, :target => "_blank"
        end
      end
      
      attributes_table do
        row :id
        row :uid
        row :provider
        row :default_account
        row :node_id
      end
      
      attributes_table do
        row :provider_token
        row :provider_secret
      end
      
      attributes_table do
        row :last_update
        row :created_at
        row :updated_at        
      end
      
    end
    
    index do
      column :id
      column :user do |a|
        link_to a.user.name, admin_user_path(a.user)
      end
      column :provider
      column :uid
      column :default_account
      column :created_at
      
      default_actions
    end
    
    form do |f|
      f.inputs "User Details" do
      
    end
    
    f.buttons
  end
end
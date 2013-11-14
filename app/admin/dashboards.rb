ActiveAdmin::Dashboards.build do
  ActiveAdmin.register AdminUser do 
    filter :email
    
    show do |ad|
      attributes_table do
        row :id
        row :email
        row :sign_in_count
        row :current_sign_in_at
        row :current_sign_in_ip
        row :last_sign_in_at
        row :last_sign_in_ip
      end
    end
    
    index do
      column :email
      column :last_sign_in_at
      column :last_sign_in_ip
      
      default_actions
    end
    
    form do |f|
      f.inputs "Admin Details" do
        f.input :email
        f.input :password
        f.input :password_confirmation
      end
      f.buttons
    end
  end
  
  ActiveAdmin.register Transport do
    filter :user_id, :as => :numeric
    filter :start_time
    
    index do
      column :id
      column :user do |a|
        link_to a.user.name, admin_user_path(a.user)
      end
      column :title
      column :cost
      column :start_time
      
      default_actions
    end
  end
  
  ActiveAdmin.register TransportsRequest do
    filter :user_id, :as => :numeric
    filter :transport_id, :as => :numeric
    filter :status
    
    index do
      column :id
      column :transport do |a|
        link_to a.transport.title, admin_transport_path(a.transport)
      end
      column :user do |a|
        link_to a.user.name, admin_user_path(a.user)
      end
      column :for_persons
      column :status
      column :created_at
      
      default_actions
    end
  end
  
  
  # Define your dashboard sections here. Each block will be
  # rendered on the dashboard in the context of the view. So just
  # return the content which you would like to display.
  
  # == Simple Dashboard Section
  # Here is an example of a simple dashboard section
  #
  #   section "Recent Posts" do
  #     ul do
  #       Post.recent(5).collect do |post|
  #         li link_to(post.title, admin_post_path(post))
  #       end
  #     end
  #   end
  
  # == Render Partial Section
  # The block is rendered within the context of the view, so you can
  # easily render a partial rather than build content in ruby.
  #
  #   section "Recent Posts" do
  #     div do
  #       render 'recent_posts' # => this will render /app/views/admin/dashboard/_recent_posts.html.erb
  #     end
  #   end
  
  # == Section Ordering
  # The dashboard sections are ordered by a given priority from top left to
  # bottom right. The default priority is 10. By giving a section numerically lower
  # priority it will be sorted higher. For example:
  #
  #   section "Recent Posts", :priority => 10
  #   section "Recent User", :priority => 1
  #
  # Will render the "Recent Users" then the "Recent Posts" sections on the dashboard.
end
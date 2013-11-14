ActiveAdmin.register GroupsUser do
  filter :id
  filter :user_id, :as => :numeric
  filter :group_id
  
  show do |gu|
    attributes_table do
      row :id
    end
    
    attributes_table do
      row :user_id do
        link_to gu.user.name, admin_user_path(gu.user), :target => "_blank"
      end
      row :group_id do
        link_to gu.group.name, admin_group_path(gu.group), :target => "_blank"
      end
    end
  end
  
  index do
    column :id
    column :user do |g|
      link_to g.user.name, admin_user_path(g.user)
    end
    
    column :group do |g|
      link_to g.group.name, admin_group_path(g.group)
    end
    default_actions
  end
  
  form do |f|
    f.inputs "Groups Users" do
      f.input :group
      f.input :user_id
    end
    f.buttons
  end
end

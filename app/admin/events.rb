ActiveAdmin.register Event do
  filter :id
  filter :title
  filter :start_time
  
  show do |ev|
    attributes_table do
      row :id
      row :title
    end
    
    attributes_table do
      row :start_time
      row :start_lng
      row :start_lat
      row :page_url do |e|
        link_to "Event URL", ev.page_url, :target => "_blank"
      end
    end
  end
  
  index do
    column :id
    column :title
    
    column :page_url do |e|
      link_to "Event URL", e.page_url, :target => "_blank"
    end
    
    default_actions
  end
end

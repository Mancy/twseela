ActiveAdmin.register Group do
  filter :id
  filter :name
  
  show do |gr|
    attributes_table do
      row :small_image_url do |g|
        image_tag(gr.small_image_url)
      end
      row :image_url do |g|
        image_tag(gr.image_url)
      end
    end
    
    attributes_table do
      row :id
      row :name
    end
    
    attributes_table do
      row :created_at
    end
  end
  
  index do
    column :id
    column :name
    
    default_actions
  end
end

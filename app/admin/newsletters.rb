ActiveAdmin.register Newsletter do
  actions :index, :new, :show
  
  controller do
    def create
      @newsletter = Newsletter.new(params[:newsletter])
      users_list = User.select(:email).newsletter_notifications
      
      if @newsletter.has_cars.to_s == "has_car"
        users_list = users_list.have_cars
      elsif @newsletter.has_cars.to_s == "has_not_car"
        users_list = users_list.have_not_cars
      end
      
      @newsletter.emails = users_list.collect(&:email)
      
      if @newsletter.valid? && @newsletter.save
        @newsletter.send_mail
        redirect_to admin_newsletters_path, :notice => 'Newsletter was successfully sent.'
      else
        render :new
      end
    end
  end
  
  index do
    column :id
    column :title
    column :created_at
    
    default_actions
  end
  form do |f|
    f.inputs "Admin Details" do
      f.input :title
      f.input :body
      f.input :has_cars, :as => :select, :collection => [:all, :has_car, :has_not_car]
    end
    f.buttons
  end
    
end
class TransportsController < ApplicationController
  load_resource :find_by => :find_encoded # will use find_by_permalink!(params[:id])
  before_filter :prepare_list, :only => [:new, :results]
  authorize_resource :except => [:show, :upcoming]
  
  def upcoming
    @par = {:user_id => params[:user_id], 
            :lat => params[:lat], 
            :lng => params[:lng],
            :event_time => params[:event_time],
            :limit => !params[:limit].blank? && (params[:limit].to_i > 0 && params[:limit].to_i < 11 ) ? params[:limit].to_i : 5,
            :width => !params[:width].blank? && (params[:width].to_i > 220 ) ? params[:width].to_i : 220 }
    
    
    account = Account.find_by_uid(@par[:user_id].to_s) unless @par[:user_id].blank?
    
    #Transport.uncached do
      if account
        @transports = Transport.next_dates.has_seats.order("start_time asc").where("user_id <> #{account.user_id}").where(:user_id => account.user.friends_ids)
      else
        @transports = Transport.next_dates.has_seats.order("start_time asc")
      end
    #end 
    
    if !@par[:event_time].blank?
      event_time = Time.parse(@par[:event_time])
      @transports = @transports.where("start_time >= '#{event_time - 1.day}'") unless event_time.blank?
      @transports = @transports.where("start_time <= '#{event_time + 1.day}'") unless event_time.blank?
    end
    
    if !@par[:lat].blank? && !@par[:lng].blank?
      points = []
      factory = ::RGeo::Geographic.simple_mercator_factory()
      #points should be more than 1 point 
      points << factory.point(@par[:lng], @par[:lat])
      points << factory.point(@par[:lng], @par[:lat])
      
      transports_ids = TransportsRoute.next_dates.where("ST_Distance(path, ST_GeomFromText('#{factory.line_string(points).as_text}', 4326) ) < 0.0013").select(:transport_id)
      @transports = @transports.where(:id => transports_ids.collect(&:transport_id))
    end
    
    @transports = @transports.limit(@par[:limit])
    
    respond_to do |format|
      format.html {render :layout => false}
      format.js {render :status => :ok}
    end
  end
  
  def index
    #Transport.uncached do
    @transports = current_user.transports.running.order("start_time asc")
    @prev_transports = current_user.transports.previous.order("start_time desc").page(params[:page]).per(Transport.per_page)
    #end
    
    respond_to do |format|
      format.html
      # format.json { render json: @transports }
    end
  end
  
  def show
    @title = @transport.title
    @description = "#{t('tawseela')} - #{l(@transport.start_time, :format => :short)} - #{t('navigation.from')}: #{@transport.start_place}, #{t('navigation.to')}: #{@transport.end_place}"
    
    @transport = Transport.find_encoded(params[:id])
    authorize! :show, @transport
    
    
    @transports_requests = []
    if current_user && current_user.id == @transport.user_id 
      @transports_requests = @transport.transports_requests.order("status asc")
    elsif current_user && !@transport.transports_requests.where(:user_id => current_user.id).accepted.blank?
      @transports_requests = @transport.transports_requests.accepted
    elsif current_user
      @transports_requests = @transport.transports_requests.where(:user_id => current_user.id)
    end
    
    if current_user
      @latest_transports = Transport.next_dates.has_seats.where("user_id <> #{current_user.id}").where("id <> #{@transport.id}").where(:user_id => current_user.friends_ids).limit(5)
    end
    
    flash[:warning] = t("messages.cant_save", :login_link => "<a style='color:#C9581F;font-weight: bold;' href='/login'><strong>#{t('navigation.with_login')}</strong></a>").html_safe unless current_account
    
    respond_to do |format|
      format.html
      format.json { render json: @transport.transport_data(@transports_requests, current_user) }
    end
  end
  
  def new
    if !current_account
      flash[:warning] = t("messages.cant_save", :login_link => "<a style='color:#C9581F' href='/login'><strong>#{t('navigation.with_login')}</strong></a>").html_safe
    elsif current_account.user.has_car != true
      flash[:error] = t("transports.cant_add_transport")
      redirect_to root_path
      return true
    end
    
    
    if params[:saved_transport].blank?
      @transport = Transport.new()
      @saved_transports = current_user ? current_user.transports.saved_only : []
    else
      transport = Transport.find(Encoder.decode(params[:saved_transport]))
      transport_attributes = transport.attributes
      transport_attributes.merge("id" => nil, "start_time" => nil, "templ_saved" => false, "user_id" => nil, "created_at" => nil, "updated_at" => nil, "flags_count" => nil, "rates_count" => nil)
      @transport = Transport.new(transport_attributes)
      @transport.templ_saved = false 
      @transport.start_time = nil
      @transport.cost = 0 if @transport.cost_type == CostType.free
      @transport.saved_transport = params[:saved_transport]
      @transport.paths = transport.points_list_to_hash
    end
  end
  
  def edit
    @transport = Transport.find_encoded(params[:id])
    
    @transport.start_time = "#{l(@transport.start_time, :format => :short)} UTC+2" if !@transport.start_time.blank?
    @transport.return_back_start_time = "#{l(@transport.return_back_start_time, :format => :long)} UTC+2" if !@transport.return_back_start_time.blank? 
  end
  
  def create
    @transport = Transport.new(params[:transport])
    @transport.user = current_user
    @transport.cost = 0 if @transport.cost_type == CostType.free
    # if @transport.cost_type == CostType.free && params[:transport_total_cost].to_f > 0 
    #   cost = (params[:transport_total_cost].to_f * 10 ) / 100 
    #   @transport.cost = cost > 1 ? cost : 1
    # end
    
    if !params[:transport].blank? && !params[:transport][:start_time].blank? && !params[:transport][:start_time].include?("UTC")
      @transport.start_time = "#{params[:transport][:start_time]} UTC+2" 
    elsif !params[:transport_start_time_date_only].blank? && !params[:transport_start_time_time_only].blank?
      @transport.start_time = "#{params[:transport_start_time_date_only]} #{params[:transport_start_time_time_only]} UTC+2"
    end

    if !params[:transport].blank? && !params[:transport][:return_back_start_time].blank? && !params[:transport][:return_back_start_time].include?("UTC")
      @transport.return_back_start_time = "#{params[:transport][:return_back_start_time]} UTC+2" 
    elsif !params[:transport_return_back_start_time_date_only].blank? && !params[:transport_return_back_start_time_time_only].blank?
      @transport.return_back_start_time = "#{params[:transport_return_back_start_time_date_only]} #{params[:transport_return_back_start_time_time_only]} UTC+2"
    end    
    

    @transport = update_geo_route(@transport)
    
    share_msg = ""
    repeat_days = @transport.repeat_days
    
    respond_to do |format|
      begin
        Transport.transaction do
          if @transport.save
            @transport = Transport.find(@transport)
            @transport.repeat_days = repeat_days
            @transport.repeat_days.each do |repeat_day|
              transport_attributes = @transport.attributes
              transport_attributes.merge("id" => nil, "templ_saved" => false, "user_id" => current_user.id, "created_at" => nil, "updated_at" => nil, "flags_count" => nil, "rates_count" => nil, "repeat_days" => nil)
              
              target_time = @transport.start_time.date_of_next(Day.wday_of(repeat_day.to_sym))
              
              new_transport = Transport.new(transport_attributes)
              new_transport.templ_saved = false 
              new_transport.start_time = Time.mktime(target_time.year, target_time.month, target_time.day, @transport.start_time.hour, @transport.start_time.min)
              new_transport.return_back_start_time = Time.mktime(target_time.year, target_time.month, target_time.day, @transport.return_back_start_time.hour, @transport.return_back_start_time.min) unless @transport.return_back_start_time.blank?
              new_transport.paths = @transport.points_list_to_hash
              new_transport = update_geo_route(new_transport)
              new_transport.save
            end if @transport.repeat_days
            
            Notification.create(:user => current_user , :notifiable => @transport, :notification => "notifications.added_transport")
            
            if params[:transport][:share_transport].to_s == "1"
              Resque.enqueue(ProviderShare, @transport.user_id, :transport_share, @transport.user.accounts.collect(&:provider), @transport.id)
              Resque.enqueue(EmailsShare, :new_transport, @transport.id)
              share_msg = t("messages.will_share")
            end
            
            
            
            format.html { redirect_to @transport, notice: t("messages.transport_created") + share_msg }
            format.json { render json: {:transport_id => @transport.id}, status: :created, location: @transport }
          else
            @saved_transports = current_user.transports.saved_only
            format.html { render action: "new" }
            format.json { render json: @transport.errors.full_messages, status: :unprocessable_entity }
          end
        end
      rescue => e
        raise e if Rails.env.development?
        @saved_transports = current_user.transports.saved_only
        @transport.repeat_days = repeat_days
        format.html { render action: "new" }
        format.json { render json: @transport.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update
    @transport = Transport.find_encoded(params[:id])
    @transport.attributes = params[:transport]
    @transport.cost = 0 if @transport.cost_type == CostType.free
    # if @transport.cost_type == CostType.free && params[:transport_total_cost].to_f > 0 
    #   cost = (params[:transport_total_cost].to_f * 10 ) / 100 
    #   @transport.cost = cost > 1 ? cost : 1
    # end
    
    @transport.start_time = "#{params[:transport][:start_time]} UTC+2" if !params[:transport].blank? && !params[:transport][:start_time].blank? && !params[:transport][:start_time].include?("UTC")
    @transport.return_back_start_time = "#{params[:transport][:return_back_start_time]} UTC+2" if !params[:transport].blank? && !params[:transport][:return_back_start_time].blank? && !params[:transport][:return_back_start_time].include?("UTC")
    
    @transport = update_geo_route(@transport)
    
    respond_to do |format|
      if @transport.save
        format.html { redirect_to @transport, notice: t("messages.updated") }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @transport.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def delete
    @transport = Transport.find_encoded(params[:id])
    @transport.destroy
    #todo 
    #notify users
    
    respond_to do |format|
      format.html { redirect_to transports_url, notice: t("messages.deleted") }
      format.json { head :ok }
    end
  end
  
  def transports_requests
    @transports_requests = current_user.transports_requests.page(params[:page]).per(Transport.per_page)
  end
  
  def repeat
    transport = Transport.find_encoded(params[:id])
    
    transport_attributes = transport.attributes
    transport_attributes.merge("id" => nil, "templ_saved" => false, "user_id" => current_user.id, "created_at" => nil, "updated_at" => nil, "flags_count" => nil, "rates_count" => nil)
    
    target_time = Date.today + 1.day

    @transport = Transport.new(transport_attributes)
    @transport.templ_saved = false 
    @transport.start_time = Time.mktime(target_time.year, target_time.month, target_time.day, transport.start_time.hour, transport.start_time.min)
    @transport.return_back_start_time = Time.mktime(target_time.year, target_time.month, target_time.day, transport.return_back_start_time.hour, transport.return_back_start_time.min) unless transport.return_back_start_time.blank?
    @transport.paths = transport.points_list_to_hash
    
    @transport = update_geo_route(@transport)
    
    respond_to do |format|
      if @transport.save
        
        Notification.create(:user => current_user , :notifiable => @transport, :notification => "notifications.added_transport")
        #Resque.enqueue(ProviderShare, @transport.user_id, :transport_share, @transport.user.accounts.collect(&:provider), @transport.id)
        
        format.html { redirect_to @transport, notice: t("messages.repeated", :share_link => "<a style='color:#C9581F' href='/transports/#{@transport.to_param}/share'><strong>#{t('navigation.share')}</strong></a>").html_safe }
        format.json { head :ok }
      else
        flash[:error] = t("messages.not_repeated")
        format.html { redirect_to @transport }
        format.json { render json: @transport.errors, status: :unprocessable_entity }
      end
    end
    
  end
  
  def share
    @transport = Transport.find_encoded(params[:id])
    Resque.enqueue(ProviderShare, @transport.user_id, :transport_share, @transport.user.accounts.collect(&:provider), @transport.id)
    
    respond_to do |format|
      format.html { redirect_to @transport, notice: t("messages.transport_shared") }
      format.json { render json: @transport.attributes.merge(:transports_paths => @transport.points_list), status: :created }
    end
  end

  def get_token
    respond_to do |format|
      format.html {render text: "", status: 200}
      format.json {render json: {:csrf_token => form_authenticity_token}, status: 200}
    end
  end
  
  #########
  protected
  #########
  
  def prepare_list
    @latest_users = current_user ? User.where("id <> #{current_user.id}").where(:id => current_user.friends_ids).order("created_at desc").limit(15) : []
  end
  
  def set_title
    @title = t("transports.transports")
  end
  
  def update_geo_route(trans)
    #save geo
    points = []
    # factory = RGeo::Geos.factory
    # factory = ::RGeo::Cartesian.preferred_factory
    factory = ::RGeo::Geographic.simple_mercator_factory()
    trans.points_list.each do |point|
      points << factory.point(point[:start_lng], point[:start_lat])
    end
    
    transports_route = trans.transports_route || TransportsRoute.new
    transports_route.attributes = {:transport_start_time => trans.start_time, :path => factory.line_string(points)}
    trans.transports_route = transports_route
    trans
  end
end

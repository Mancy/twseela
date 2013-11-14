class SearchesController < ApplicationController
  before_filter :prepare_list, :only => [:new, :results]
  
  def my_searches
    @searches = current_user ? current_user.searches : []
    authorize! :my_searches, @searches
  end
  
  def results
    params[:search] ||= {}
    @search = Search.new(params[:search].merge(:user_id => current_user.try(:id)))
    authorize! :results, @search
    
    if @search.valid? 
      search_results(@search)
      @search.save if @search.save_search.to_i == 1
    end
    
    respond_to do |format|
      if @search.valid?
        format.html do
          flash[:notice] = t("messages.search_saved") if @search.save_search.to_i == 1
        end
        format.json { render json: Transport.transports_data(@transports)}
      else
        format.html { render action: "new" }
        format.json { render json: @search.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @search = Search.find(params[:id])
    authorize! :show, @search
    
    search_results(@search)
    
    respond_to do |format|
      format.html 
      format.json { render json: @transports }
    end
  end
  
  def new
    @search = Search.new
    authorize! :new, @search
    
    if current_user
      flash_warning = nil
      @transports_list = Transport.next_dates.has_seats.order("start_time asc").where("user_id <> #{current_user.id}").where(:user_id => current_user.friends_ids).limit(5)
    else
      flash_warning = t("messages.cant_save", :login_link => "<a style='color:#C9581F;font-weight: bold;' href='/login'><strong>#{t('navigation.with_login')}</strong></a>").html_safe
      @transports_list = Transport.next_dates.has_seats.order("start_time asc").limit(5)
    end

    respond_to do |format|
      format.html { render :new, warning: flash_warning }
      format.json { render json: Transport.transports_data(@transports_list) }
    end
  end
  
  def edit
    @search = Search.find(params[:id])
    authorize! :edit, @search
  end
  
  def update
    @search = Search.find(params[:id])
    authorize! :update, @search

    respond_to do |format|
      if @search.update_attributes(params[:search])
        format.html { redirect_to my_searches_searches_path, notice: t("messages.search_updated") }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @search.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def delete
    @search = Search.find(params[:id])
    authorize! :delete, @search
    
    @search.destroy
    
    respond_to do |format|
      format.html { redirect_to new_search_path, notice: t("messages.search_deleted") }
      format.json { head :ok }
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
    if current_user
      @saved_searches = current_user.searches
      @latest_transports = [] #Transport.next_dates.has_seats.order("start_time asc").where("user_id <> #{current_user.id}").where(:user_id => current_user.friends_ids).limit(3)
    else
      @latest_transports = [] #Transport.next_dates.has_seats.order("start_time asc").limit(3)
      
      @saved_searches = []
      @latest_transports = []
    end
  end
  
  def search_results(search)
    @transports = Transport.next_dates.has_seats.order("start_time asc").where("user_id <> #{current_user.id}")
    
    points = []
    factory = ::RGeo::Geographic.simple_mercator_factory()
    
    search.searches_paths.each do |searches_path|
      points << factory.point(searches_path.start_lng, searches_path.start_lat)
    end unless search.searches_paths.blank?
    
    if points.size > 1
      transports_ids = TransportsRoute.next_dates.where("ST_Distance(path, ST_GeomFromText('#{factory.line_string(points).as_text}', 4326) ) < 0.0013").select(:transport_id)
      @transports = @transports.where(:id => transports_ids.collect(&:transport_id))
    end
    
    @transports = @transports.where(:user_id => current_user.friends_ids)
    @transports = @transports.where("start_time >= '#{search.start_time_from}'") unless search.start_time_from.blank?
    @transports = @transports.where("start_time <= '#{search.start_time_to}'") unless search.start_time_to.blank?
    @transports = @transports.where(:cost_type => search.cost_type) unless search.cost_type.blank?
    @transports = @transports.where(:air_cond => search.air_cond) unless search.air_cond.blank?
    @transports = @transports.where(:cassette => search.cassette) unless search.cassette.blank?
    @transports = @transports.where(:smoking => search.cassette) unless search.smoking.blank?
    @transports = @transports.where(:return_back => search.cassette) unless search.return_back.blank?
    
    #todo
    #search within cost
    
    @transports = @transports.page(params[:page]).per(Transport.per_page)
  end
  
  def set_title
    @title = t("searches.searches")
  end
end

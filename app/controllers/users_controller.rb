class UsersController < ApplicationController
  # authorize_resource
  skip_before_filter :validate_user, :only =>[:new, :edit, :create, :update]
  before_filter :prepare_lists, :only =>[:new, :edit, :create, :update]
  
  def dashboard
    @user = User.find(params[:id])
    authorize! :dashboard, @user
    
    @transports = @user.transports.order("start_time desc").limit(5)
    @transports_requests = @user.transports_requests.order("created_at desc").limit(5)
  end
  
  def index
    @user = User.new(params[:user])
    authorize! :index, @user
    @user.friends_type = nil
    
    @users = User.order("created_at desc").where("id <> #{current_user.id}")
    @users = @users.where(:id => current_user.all_friends_ids)
    @users = @users.page(params[:page]).per(User.per_page)
    
    unless params[:utf8].blank?
      @users = @users.search("#{@user.name}:*") unless @user.name.blank?
      @users = @users.where(:email => @user.email) unless @user.email.blank?
      @users = @users.where(:mobile => @user.mobile) unless @user.mobile.blank?
      @users = @users.where(:gender => @user.gender) unless @user.gender.nil?
      @users = @users.where(:has_car => @user.has_car) unless @user.has_car.nil?
      
      if @user.filter_group && @user.filter_group.to_i > 0
        groups_users_ids = Group.find(@user.filter_group).users.select("users.id").collect(&:id)
        @users = @users.where(:id => groups_users_ids)
      end
    end
    respond_to do |format|
      format.html
      format.json { render json: @users.size > 0 ? @users : nil }
    end
  end
  
  def show
    @user = User.find(params[:id])
    authorize! :show, @user
    
    @title = @user.name
    respond_to do |format|
      format.html {render :layout => (params[:layout] != "false")}
      format.json { render json: user_data(@user) }
    end
  end
  
  def new
    @user = User.new
    authorize! :new, @user
    
    @user.has_car = false
    @user.default_locale = I18n.locale.to_s
    @account = Account.new(:user => @user)
    
    @title = t("users.new_user")

    respond_to do |format|
      format.html
      format.json { render json: session[:login_attrs], status: 200 }
    end
  end
  
  def edit
    @user = User.find(params[:id])
    authorize! :edit, @user
    
    @account = Account.new(:user => @user)
    @title = t("navigation.edit_profile")
    respond_to do |format|
      format.html
      format.json { render json: @user.attributes.merge(:accounts => @user.accounts) }
    end
  end
  
  def create
    @user = User.new(params[:user])
    authorize! :create, @user
    
    @user.accounts[0].default_account = true if @user.accounts[0]
    @title = t("users.new_user")
    
    respond_to do |format|
      begin
        User.transaction do
          
          @user.last_login = Time.now
          #@user.save
        
          if @user.save
            MoneyTransaction.add_transaction(@user, MoneyTransactionType.init_val, INIT_CREDITS)
            session[:account_id] = @user.accounts[0].id
            session[:login_attrs] = nil
            
            Resque.enqueue(ProviderFriends, @user.accounts[0].id)
            Resque.enqueue(ProviderShare, @user.id, :register_share, [@user.accounts[0].provider]) if params[:user][:share_registration].to_s == "1"
            Notification.create(:user => current_user , :notifiable => @user, :notification => "notifications.registered")
            UserMailer.welcome(@user.id).deliver if ENABLE_MAIL_SHARE
            
            format.html { redirect_to root_path, notice: t("messages.user_created") }
            format.json { render json: user_data(@user), status: :created }
          else
            @account = @user.accounts[0] || Account.new
            @account.user = @user
            
            format.html { render action: "new" }
            format.json { render json: @user.errors.full_messages, status: :unprocessable_entity }
          end
        end
      end
    end
  end
  
  def update
    @user = User.find(params[:id])
    authorize! :update, @user
    
    @user.attributes = params[:user]
    
    trust_level_changed = @user.trust_level_changed? ? true : false
    friends_type_changed = @user.friends_type_changed? ? true : false
    
    
    respond_to do |format|
      if @user.save
        if trust_level_changed || friends_type_changed
          Resque.enqueue(ProviderFriends, current_account.id) if trust_level_changed
          @user.reset_friends_ids_cache
        end 
        
        format.html { redirect_to root_path, notice: t("messages.updated") }
        format.json { head :ok }
      else
        @account = Account.new(:user => @user)
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def merge_accounts
    @user = current_user
    authorize! :merge_accounts, @user
    
    accounts = @user.accounts.collect{|a| a.provider}
    @accounts = ["facebook", "twitter", "linked_in"] -  accounts
  end
  
  def update_default_account
    @account = Account.find(params[:account_id])
    @user = @account.user
    authorize! :update_default_account, @user
    
    
    Account.update_all "default_account = false", "user_id = #{@account.user_id}"
    @account = Account.find(@account.id)
    
    @account.default_account = true
    @account.save
    
    redirect_to merge_accounts_user_path(current_user), :notice => t("messages.account_updated")
  end
  
  def get_current_user
    if current_user
      @user = current_user
      authorize! :get_current_user, @user
    end
    
    respond_to do |format|
      format.html {render text: "", status: 200}
      format.json {render json: user_data(current_user), status: 200}
    end
  end
  
  def check_current_user
    respond_to do |format|
      format.json {render json: !!current_user, status: 200}
    end
  end
  
  def get_token
    respond_to do |format|
      format.html {render text: "", status: 200}
      format.json {render json: {:csrf_token => form_authenticity_token}, status: 200}
    end
  end
  
  def invite_friends
    @user = User.find(params[:id])
    authorize! :invite_friends, @user
    
    Resque.enqueue(ProviderShare, @user.id, :invite_friends, @user.accounts.collect(&:provider))
    
    respond_to do |format|
      format.html {redirect_to @user, :notice => t("messages.invite_friends_sent")}
      format.json {render status: 200}
    end
  end
  
  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :ok }
    end
  end
  
  #########
  protected
  #########
  
  def prepare_lists
    @carsmakes = CarsMake.all
    @gasoline_type = GasolineType.all
    @cities = City.all
  end
  
  def user_data(user)
    data = nil    
    
    
    if user
      default_account = user.accounts.default_one.first
      data = user.attributes.merge(:default_account => default_account.attributes.merge(:my_image => default_account.my_image),
                                    :car_profiles => user.car_profiles.collect(&:hash_data),
                                    :gender_name => user.gender_name,
                                    :default_locale_name => user.default_locale_name,
                                    :trust_level_name => user.trust_level_name,
                                    :city_name => user.city_name,
                                    :friends_count => (user.all_friends_ids.size - 1))
    end

    data
  end

  def set_title
    @title = t("users.users")
  end
end

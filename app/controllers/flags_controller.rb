class FlagsController < ApplicationController
  def new
    flaggable = Transport.find_encoded(params[:transport_id]) unless params[:transport_id].blank?
    flaggable = TransportsRequest.find(params[:transports_request_id]) unless params[:transports_request_id].blank?
    flaggable ||= nil
    
    @flag = Flag.new(:user_id => current_user.id, :flaggable => flaggable)
    authorize! :new, @flag
    
    redirect_url = "/transports/#{@flag.flaggable.to_param}" if @flag.flaggable_type == "Transport"
    redirect_url = "/transports/#{@flag.flaggable.transport.to_param}" if @flag.flaggable_type == "TransportsRequest"
    redirect_url ||= "/#{@flag.flaggable_type.downcase.pluralize}"
    @back_url = redirect_url
    
    respond_to do |format|
      format.html {render :layout => (params[:layout] != "false")}
      format.json { render json: @flag }
    end
  end
  
  def create
    flaggable_class = eval(params[:flag][:flaggable_type])
    flaggable =flaggable_class.find(params[:flag][:flaggable_id])
    @flag = Flag.new(:flaggable => flaggable, :user => current_user)
    authorize! :create, @flag
    
    @flag.attributes =  params[:flag]
    
    redirect_url = "/transports/#{@flag.flaggable.to_param}" if @flag.flaggable_type == "Transport"
    redirect_url = "/transports/#{@flag.flaggable.transport.to_param}" if @flag.flaggable_type == "TransportsRequest"
    redirect_url ||= "/#{@flag.flaggable_type.downcase.pluralize}"
    @back_url = redirect_url
    
    
    
    respond_to do |format|
      if @flag.save
        Notification.create(:user => current_user , :notifiable => @flag, :notification => "notifications.added_flag")
        
        #todo 
        #notify users
    
        format.html { redirect_to redirect_url, notice: t("messages.flag_created") }
        format.json { render json: @flag, status: :created, location: @flag }
      else
        format.html { render action: "new" }
        format.json { render json: @flag.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def delete
    @flag = Flag.find(params[:id])
    authorize! :delete, @flag
    
    @flag.destroy if @flag
    
    redirect_url = "/transports/#{@flag.flaggable.to_param}" if @flag.flaggable_type == "Transport"
    redirect_url = "/transports/#{@flag.flaggable.transport.to_param}" if @flag.flaggable_type == "TransportsRequest"
    redirect_url ||= "/#{@flag.flaggable_type.downcase.pluralize}"
    
    #todo 
    #notify users
    
    respond_to do |format|
      format.html { redirect_to redirect_url, notice: t("messages.flag_deleted")}
      format.json { head :ok }
    end
  end
  
  #########
  protected
  #########
  
  def set_title
    @title = t("flags.flags")
  end
end
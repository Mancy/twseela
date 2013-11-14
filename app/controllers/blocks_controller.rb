class BlocksController < ApplicationController
  def index
    @user = User.find(params[:user_id])
    @block = Block.new(:user_id => @user.id)
    authorize! :index, @block
    
    @blocks = @user.blocks.page(params[:page]).per(Block.per_page)

    respond_to do |format|
      format.html
      format.json { render json: @blocks }
    end
  end

  def new
    @user = User.find(params[:user_id])
    blocked = User.find(params[:blocked_id])
    @block = Block.new(:blocked_id => blocked.id, :user_id => @user.id)
    authorize! :new, @block
    
    @user.blocks << @block if @user.blocks.for_blocked(blocked.id).blank?
    
    respond_to do |format|
      if @user.save
        
        @user.reset_friends_ids_cache
        blocked.reset_friends_ids_cache
        
        format.html { redirect_to users_path , :notice => t("messages.user_blocked") }
        format.json { render json: @user }
      else
        format.html { redirect_to request.env["HTTP_REFERER"] || "/", :notice => @user.errors.full_messages }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def delete
    @block = Block.find(params[:id])
    authorize! :delete, @block
    
    @block.destroy
    
    @block.user.reset_friends_ids_cache
    @block.blocked.reset_friends_ids_cache
    
    respond_to do |format|
      format.html { redirect_to request.env["HTTP_REFERER"] || "/", :notice => t("messages.user_un_blocked") }
      format.json { head :ok }
    end
  end
  
  #########
  protected
  #########
  
  def set_title
    @title = t("blocks.blocks")
  end
end
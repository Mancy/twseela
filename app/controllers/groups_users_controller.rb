class GroupsUsersController < ApplicationController
  authorize_resource
  
  def new
    @groups_users = GroupsUser.new
  end
  
  def create
    valid = false
    @groups_users = GroupsUser.new(:group_id => params[:group_id])
    if !params[:email].blank? && !params[:full_name].blank?
      user = User.find_by_email_and_name(params[:email], params[:full_name])
      if user
        @groups_users.user_id = user.id
        valid = @groups_users.valid?
      else
        @groups_users.errors.add(:user_id, t("messages.not_exists"))
      end 
    else
      @groups_users.valid?
    end
    
    if valid
      @groups_users.save
      redirect_to users_path, notice: t("messages.groups_users_added")
    else
      render action: "new"
    end
  end
  
  #########
  protected
  #########
  
  def set_title
    @title = t("groups_users.groups_users")
  end
end

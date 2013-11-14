class GroupsUser < ActiveRecord::Base
  validates :user_id, :group_id, :presence=>true
  
  validates :user_id, :uniqueness=>{:scope => [:group_id], :message=>I18n.t("messages.already_added")}
  
  belongs_to :user
  belongs_to :group
end

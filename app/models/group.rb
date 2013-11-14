class Group < ActiveRecord::Base
  validates :name, :presence=>true
  has_and_belongs_to_many :users
  after_save :update_users_is_free
  
  def update_users_is_free
    if self.is_free_changed?
      self.users.update_all(:is_free => self.is_free)
    end
  end
end
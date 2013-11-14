class City < ActiveRecord::Base
  has_many :users, :dependent=>:destroy
  validates :name_ar, :name_en, :presence=>true
  
  default_scope order("name_#{I18n.locale}")
  
  def name
    send("name_#{I18n.locale}")
  end
end
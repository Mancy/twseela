class GasolineType < ActiveRecord::Base
  has_many :car_profiles, :dependent=>:destroy
  
  validates :name, :presence=>true, :length=>{:maximum=>250}
  validates :price, :presence=>true
  
  default_scope order("name_#{I18n.locale}")
  def name
    self.send("name_#{I18n.locale}")
  end
end

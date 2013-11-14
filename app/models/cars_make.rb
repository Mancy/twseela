class CarsMake < ActiveRecord::Base
  has_many :car_profiles, :dependent=>:destroy
  
  validates :name_en, :name_ar, :presence=>true, :length=>{:minimum=>2, :maximum=>20}
  
  default_scope order("name_#{I18n.locale}")
  def name
    self.send("name_#{I18n.locale}")
  end
end

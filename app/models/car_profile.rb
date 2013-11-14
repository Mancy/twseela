class CarProfile < ActiveRecord::Base
  belongs_to :cars_make
  belongs_to :user
  belongs_to :gasoline_type
  has_many :transports, :dependent=>:destroy
  
  validates :cars_make, :gasoline_type, :presence=>true
  validates :number, :presence=>true
  validates :number, :length=>{:minimum=>2, :maximum=>20}, :unless => Proc.new{|cp| cp.number.blank?}
  validates :model_name, :presence=>true
  validates :model_name, :length=>{:minimum=>2, :maximum=>20}, :unless => Proc.new{|cp| cp.model_name.blank?}
  validates :color, :presence=>true
  validates :make_date, :presence=>true
  #validates :make_date, :length => { :within => (Time.now.year - 50)..(Time.now.year + 1) }
  
  def car_make_name
    self.cars_make.name_ar if self.cars_make
  end
  
  def gasoline_type_name
    self.gasoline_type.name if self.gasoline_type
  end
  
  def gas_cost
    self.gasoline_type.price if self.gasoline_type
  end
  
  def hash_data
    {:id => self.id,
      :number => self.number,
      :color => self.color,
      :make_date => self.make_date,
      :model_name => self.model_name,
      :car_make_name => self.car_make_name,
      :gasoline_type_name => self.gasoline_type_name,
      :gas_cost => self.gas_cost
    }
  end
end

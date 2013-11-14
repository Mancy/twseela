class Gender
  @@genders = {:male => 1, :female => 2, :any => 3}
  
  def self.gender_ids
    @@genders.values
  end
  
  def self.male
    @@genders[:male]
  end
  
  def self.female
    @@genders[:female]
  end
  
  def self.any
    @@genders[:any]
  end
end
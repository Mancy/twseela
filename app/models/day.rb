class Day
  @@days = {:sunday => 0, :monday => 1, 
            :tuesday => 2, :wednesday => 3, 
            :thursday => 4, :friday => 5, 
            :saturday => 6}
            
  def self.day_ids
    @@days.values
  end
  
  def self.day_of(day_num)
    @@days.each do |key, val|
      return key.to_s if val == day_num
    end
  end
  
  def self.wday_of(day_name)
    wd = 0
    @@days.each do |key, val|
      wd = val if key == day_name.to_sym
    end
    wd
  end
  
end
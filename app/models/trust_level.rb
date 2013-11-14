class TrustLevel
  @@trust_levels = {:high => 1, :medium => 2, :low => 3, :very_low => 4, :public => 5}
  
  def self.trust_levels
    @@trust_levels.values
  end
end
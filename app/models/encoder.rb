class Encoder
  @@coder = 2
  
  def self.encode(target)
    target.to_s(@@coder).to_i
    # (target * @@coder) + 23
  end 
  
  def self.decode(target)
    target.to_s.to_i(@@coder)
    # (target.to_i - 23) / @@coder
  end
end
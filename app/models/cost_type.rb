class CostType
  @@cost_types = {:paid => 1, :free => 2}
  
  def self.cost_type_ids
    @@cost_types.values
  end
  def self.paid
    @@cost_types[:paid]
  end
  
  def self.free
    @@cost_types[:free]
  end
end
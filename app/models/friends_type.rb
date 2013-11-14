class FriendsType
  @@types = {:friends => 1, :network => 2, :both => 3}
  
  def self.type_ids
    @@types.values
  end
  
  def self.friends
    @@types[:friends]
  end
  
  def self.network
    @@types[:network]
  end
  
  def self.both
    @@types[:both]
  end
end
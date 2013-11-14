class Status
  @@requested=1
  @@accepted=2
  @@rejected=3
  @@canceled=4
  @@completed=5
  
  def self.requested
    @@requested
  end
  def self.accepted
    @@accepted
  end
  def self.rejected
    @@rejected
  end
  def self.canceled
    @@canceled
  end
  def self.completed
    @@completed
  end
end
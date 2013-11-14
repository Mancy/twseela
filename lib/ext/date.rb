class Date
  def date_of_next(day)
    #date  = Date.parse(day)
    #delta = date > self ? 0 : 7
    delta = ((day - self.wday) % 7)
    delta = delta == 0 ? 7 : delta
    self + delta
  end
end
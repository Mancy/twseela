class Event < ActiveRecord::Base
  validates :title, :start_lng, :start_lat, :presence=>true
end

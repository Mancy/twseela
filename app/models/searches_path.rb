class SearchesPath < ActiveRecord::Base
  belongs_to :search
  
  validates :start_lng, :start_lat, :presence=>true
end

class TransportsPath < ActiveRecord::Base
  belongs_to :transport
  
  # validates :start_place, :presence=>true, :if => Proc.new{|tp| tp.road_path.blank?}
  validates :start_lng, :presence=>true, :if => Proc.new{|tp| tp.road_path.blank?}
  validates :start_lat, :presence=>true, :if => Proc.new{|tp| tp.road_path.blank?}
  validates :road_path, :presence=>true , :if => Proc.new{|tp| tp.start_lng.blank?}
  
  default_scope order("id")
  
  index do
    start_place
    road_path
  end
end
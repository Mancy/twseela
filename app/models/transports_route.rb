class TransportsRoute < ActiveRecord::Base
  establish_connection Rails.configuration.database_configuration["#{Rails.env}_geo"]
  # self.establish_connection "#{Rails.env}_geo".to_sym
  # use_db :prefix => "ad_manager_"
  
  rgeo_factory_generator = RGeo::Geos.factory_generator
  # set_rgeo_factory_for_column(:latlon, RGeo::Geographic.spherical_factory)
  
  belongs_to :transport
  scope :next_dates, lambda{
    where("transport_start_time >= '#{Time.now}'")
  }
end
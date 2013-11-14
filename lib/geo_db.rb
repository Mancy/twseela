class GeoDb < ActiveRecord::Migration
  def connection 
    TransportsRoute.connection
    # ActiveRecord::Base.establish_connection("#{Rails.env}_geo".to_sym).connection
    # Rails.configuration.database_configuration["#{Rails.env}_geo"] 
  end
end
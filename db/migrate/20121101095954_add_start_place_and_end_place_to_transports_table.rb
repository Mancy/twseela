class AddStartPlaceAndEndPlaceToTransportsTable < ActiveRecord::Migration
  def change
    add_column :transports, :start_place, :string, :default => ""
    add_column :transports, :end_place, :string, :default => ""
    
    Transport.reset_column_information
    Transport.all.each do |transport|
      transport.update_attributes({:start_place => transport.transports_paths.first.start_place, :end_place => transport.transports_paths.last.start_place}) if !transport.transports_paths.first.start_place.blank? && !transport.transports_paths.last.start_place.blank?
    end
  end
end

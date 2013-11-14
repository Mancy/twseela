class EventsController < ApplicationController
  def show
    @event = Event.find(params[:id])
    
    if current_user
      @transports = current_user.transports.next_dates.has_seats.order("start_time asc")
    else
      @transports = Transport.next_dates.has_seats.order("start_time asc")
    end 
    
    if @event.start_lat && @event.start_lng
      points = []
      factory = ::RGeo::Geographic.simple_mercator_factory()
      
      #points should be more than 1 point
      
      # points << factory.point(@event.start_lng, @event.start_lat)
      # points << factory.point(@event.start_lng, @event.start_lat)
      
      points << factory.point(@event.start_lng, @event.start_lat)
      points << factory.point(@event.start_lng, @event.start_lat)
      
      transports_ids = TransportsRoute.next_dates.where("ST_Distance(path, ST_GeomFromText('#{factory.line_string(points).as_text}', 4326) ) < 0.0013").select(:transport_id)
      
      @transports = @transports.where(:id => transports_ids.collect(&:transport_id))
    end
    
  end
  
  def set_title
    @title = t("events.events")
  end
end

class CarsMakesController < ApplicationController
  def index
    @cars_makes = CarsMake.select("id, name_#{I18n.locale}").all
    respond_to do |format|
      format.json { render json: @cars_makes, status: 200 }
    end
  end
end
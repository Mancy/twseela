class CitiesController < ApplicationController
  def index
    @cities = City.select("id, name_#{I18n.locale}").all
    respond_to do |format|
      format.json { render json: @cities, status: 200 }
    end
  end
end
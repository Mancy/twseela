class GasolineTypesController < ApplicationController
  def index
    @gasoline_types = GasolineType.select("id, name_#{I18n.locale}").all
    respond_to do |format|
      format.json { render json: @gasoline_types, status: 200 }
    end
  end
end
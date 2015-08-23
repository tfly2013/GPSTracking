class Api::LocationsController < ApplicationController
  # GET /api/locations
  # GET /api/locations.json
  def index
    @api_locations = Api::Location.all
  end

  # POST /api/locations
  # POST /api/locations.json
  def create
    @api_location = Api::Location.new(api_location_params)
    respond_to do |format|
      format.json {render :status => 200}
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def api_location_params
    params.require(:api_location).permit(:latitude, :longitude, :accuracy, :speed, :time)
  end
end

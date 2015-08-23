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
    @api_location.time = Time.at(api_location_params[:time] / 1000)
    @api_location.save
    render :status => 200, :json => { :success => true }
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def api_location_params
    params.require(:api_location).permit(:latitude, :longitude, :accuracy, :speed, :time)
  end
end


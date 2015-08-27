class Api::LocationsController < ApplicationController
  before_action :authenticate_user!, only: [:index]
  
  # GET /api/locations
  # GET /api/locations.json
  def index
    @locations = current_user.locations
  end

  # POST /api/locations
  # POST /api/locations.json
  def create
    @location = Location.new(location_params)
    @location.user = current_user
    @location.time = Time.at(location_params[:time] / 1000)
    @location.save
    render :status => 200, :json => { :success => true }
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def location_params
    params.require(:location).permit(:latitude, :longitude, :accuracy, :speed, :time)
  end
end


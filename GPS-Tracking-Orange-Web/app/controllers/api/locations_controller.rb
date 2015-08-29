class Api::LocationsController < ApplicationController
  before_action :authenticate_user!, only: [:index]
  # GET /api/locations
  # GET /api/locations.json
  def index
    @locations = current_user.locations
    @path = []
    @locations.each do |location|
      @path << location.latitude.to_s + "," + location.longitude.to_s
    end
    @raw = Gmaps4rails.build_markers(@locations) do |location, marker|
      marker.lat location.latitude
      marker.lng location.longitude
    end
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
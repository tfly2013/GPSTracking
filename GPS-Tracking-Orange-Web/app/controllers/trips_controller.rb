class TripsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trip, only: [:show, :edit, :update]

  # POST /trips
  def create
    @trip = Trip.new
    @trip.user = current_user
    @segment = Segment.new
    @segment.trip = @trip
    locations_array.each do |location_params|
      @location = Location.new(location_params)
      @location.segment = @segment
      @location.time = Time.at(location_params[:time] / 1000)
      @location.save
    end
    @segment.save
    @trip.save
    render :status => 200, :json => { :success => true }
  end

  # GET /trips
  # GET /trips.json
  def index
    @trips = current_user.trips
  end

  # GET /trips/1
  # GET /trips/1.json
  def show
    @locations = @trip.locations
    @coordinates = []
    @locations.each do |location|
      @coordinates << {:lat => location.latitude, :lng => location.longitude}
    end
  end

  # GET /trips/1/edit
  def edit
  end

  # PATCH/PUT /trips/1
  # PATCH/PUT /trips/1.json
  def update
  end

  private
  def set_trip
    @trip = current_user.trips.find(params[:id])
  end

  def locations_array
    params.permit(:locations => [:latitude, :longitude,:accuracy,:time]).require(:locations)
  end

end
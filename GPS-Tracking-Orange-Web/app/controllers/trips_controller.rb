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
    @coordinates = []
    @trip.locations.each do |location|
      @coordinates << {:lat => location.latitude, :lng => location.longitude}
    end

  end

  # GET /trips/1/edit
  def edit
    @trip = Trip.find(params[:id])
  end

  # PATCH/PUT /trips/1
  # PATCH/PUT /trips/1.json
  def update
    @trip = Trip.find(params[:id])

    if @trip.update(trip_params)
      redirect_to trips_path
    else
      render 'edit'
    end
  end

  private
  def set_trip
    @trip = current_user.trips.find(params[:id])
  end

  def locations_array
    params.permit(:locations => [:latitude, :longitude,:accuracy,:time]).require(:locations)
  end

  def trip_params
    params.require(:trip).permit(:startLocation, :endLocation)
  end
end
class TripsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trip, only: [:show, :edit, :update]

  #API
  # POST /trips
  def create
    @trip = Trip.new
    @trip.user = current_user
    @segment = Segment.new
    @segment.trip = @trip
    locations = Array.new
    locations_array.each do |location_params|
      @location = Location.new(location_params)
      @location.segment = @segment
      @location.time = Time.at(location_params[:time] / 1000)
      @locations.save
    end
    @segment.save
    @trip.save
    snap_to_road(locations)
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
    locations = @trip.locations.sort
    locations.each do |location|
      @coordinates << {:lat => location.latitude, :lng => location.longitude, :seg => location.segment.id }
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
  def snap_to_road(trip)     
    locations = trip.locations
    path = Array.new
    locations.each do |location|
      path << location.latitude.to_s + "," + location.longitude.to_s
    end
    service_url = "https://roads.googleapis.com/v1/snapToRoads"
    uri = URI.parse(service_url)
    params = {:key => "AIzaSyA-10-w06yl2bTDNkIPGT0sD52X32pAyZE", :path => path.join("|")}
    uri.query = URI.encode_www_form(params)

    request = Net::HTTP::Get.new(uri)
    request["Accept"] = "application/json"
    connection = Net::HTTP.new(uri.host, uri.port)
    connection.use_ssl = true
    connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
    response = connection.start {|http| http.request(request) }
    data = JSON.parse(response.body)

    i = 0
    data["snappedPoints"].each do |point|      
      index = point["originalIndex"]
      while index > i || locations[i].accuracy > 200
        locations[i].destroy
        i+=1
      end
      locations[index].latitude = point["location"]["latitude"]
      locations[index].longitude = point["location"]["longitude"]
      locations[index].save
      i+=1
    end
  end
  handle_asynchronously :snap_to_road

  # Algorithm
  def convert(trip)
    return trip
  end

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
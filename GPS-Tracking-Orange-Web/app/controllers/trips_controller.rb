class TripsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trip, only: [:show, :update, :destroy]

  #API
  # POST /trips
  def create
    @trip = Trip.new
    @trip.user = current_user
    @trip.validated = false
    @segment = Segment.new
    @segment.trip = @trip
    @segment.order = 0
    locations = Array.new
    Trip.transaction do
      locations_array.each_with_index do |location_params, index|
        @location = Location.new(location_params)
        @location.segment = @segment
        @location.time = Time.at(location_params[:time] / 1000)
        @location.order = index
        @location.save!
      end
      @segment.save!
      @trip.save!
    end
    @trip.snap_to_road
    render :status => 200, :json => { :success => true }
  end

  # GET /trips
  # GET /trips.json
  def index
    @trips = current_user.trips
    @unvalidated = @trips.where(:validated => false)
    @validated = @trips.where(:validated => true)
  end

  # GET /trips/1
  # GET /trips/1.json
  def show
    @tripJson = []
    @trip.segments.order(:order).each do |segment|
      locations = []
      segment.locations.order(:order).each do |location|
        locations << {:id => location.id, :lat => location.latitude, :lng => location.longitude }
      end
      @tripJson << {:id => segment.id, :transportation => segment.transportation, :locations => locations}
    end
  end

  # PATCH/PUT /trips/1
  # PATCH/PUT /trips/1.json
  def update
    Trip.transaction do
      trip_params[:segments_attributes].each do |seg_params|
        segment = nil
        if !seg_params[:id].nil?
          segment = Segment.find(seg_params[:id])
          segment.update(:order => seg_params[:order],
           :transportation => seg_params[:transportation])
        else
          segment = Segment.new
          segment.order = seg_params[:order]
          segment.transportation = seg_params[:transportation]
          segment.trip = @trip
          segment.save!
        end
        seg_params[:locations_attributes].each do |loc_params|
          if !loc_params[:id].nil?
            location = Location.find(loc_params[:id])
            location.segment = segment
            location.update(loc_params)
          else
            location = Location.new(loc_params)
            location.segment = segment
            location.save!
          end
        end
      end
      @trip.validated = true
      @trip.save!
    end
    flash[:notice] = 'Trip updated successfully.'
    flash.keep(:notice)
    render :status => 200, :json => { :success => true }
  rescue
    flash[:error] = 'Trip update failed. Please try again'
    flash.keep(:error)
    render :status => 400, :json => { :success => false }
  end

# DELETE /trips/1
def destroy
  @trip.segments.each do |seg|
    seg.locations.each do |loc|
      loc.destroy
    end
    seg.destroy
  end
  @trip.destroy
  redirect_to trips_path, :notice => "Trip deleted."
end

private
def set_trip
  @trip = current_user.trips.find(params[:id])
end

def locations_array
  params.permit(:locations => [:latitude, :longitude,:speed,:accuracy,:time]).require(:locations)
end

def trip_params
  params.require(:trip).permit(:segments_attributes =>
   [:id, :transportation, :order, :locations_attributes =>
    [:id, :latitude, :longitude, :order]])
end
end

class TripsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trip, only: [:show, :edit, :update]

  # GET /trips
  # GET /trips.json
  def index
    @trips = current_user.trips
  end

  # GET /trips/1
  # GET /trips/1.json
  def show
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

end

class SegmentsController < ApplicationController
	def new
		@trip = Trip.find(params[:trip_id])
	end

	def create
		@trip = Trip.find(params[:trip_id])
		@segment = Segment.new(segment_params)
		@segment.trip = @trip
		@segment.save
		redirect_to trip_path(@trip)
	end

	def edit
		@trip = Trip.find(params[:trip_id])
		@segment = Segment.find(params[:id])
	end

	def update
		@trip = Trip.find(params[:trip_id])
		@segment = Segment.find(params[:id])

		if @segment.update(segment_params)
			redirect_to @trip
		else
			render 'edit'
		end
	end

	def destroy
		@trip = Trip.find(params[:trip_id])
		@segment = @trip.segments.find(params[:id])
		@segment.destroy
		redirect_to trip_path(@trip)
	end

	private

    def segment_params
      params.require(:segment).permit(:startLocation, :endLocation, :transportation)
    end
end
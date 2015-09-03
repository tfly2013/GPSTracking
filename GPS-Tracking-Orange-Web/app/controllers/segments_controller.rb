class SegmentsController < ApplicationController
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

	private

    def segment_params
      params.require(:segment).permit(:id, :startLocation, :endLocation, :transportation)
    end
end
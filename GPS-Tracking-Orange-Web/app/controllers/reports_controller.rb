class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :admin_and_researcher_only

  # GET /reports
  # GET /reports.json
  def index
    trips = Trip.all
    @average_distance = average_distance(trips)
    @average_speed = average_speed(trips)
    @modes = modes_count(trips)
  end

  def admin_and_researcher_only
    unless current_user.admin? || current_user.researcher?
      redirect_to :back, :alert => "Access denied."
    end
  end

  def average_distance(trips)
    return 1000
  end

  def average_speed(trips)
    return 50
  end

  def modes_count(trips)
    modes = Hash.new(0)
    trips.each do |trip|
      trip.segments.each do |segment|
        if segment.transportation != nil
          modes[segment.transportation]+=1
        end
      end
    end
    return modes
  end
end

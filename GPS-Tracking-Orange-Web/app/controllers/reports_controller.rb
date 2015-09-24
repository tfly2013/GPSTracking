class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :admin_and_researcher_only

  # GET /reports
  # GET /reports.json
  def index
    segments = Segment.all
    @average_distance = average_distance(segments)
    @average_speed = average_speed(segments)
    @modes = modes_count(segments)
  end

  def admin_and_researcher_only
    unless current_user.admin? || current_user.researcher?
      redirect_to :back, :alert => "Access denied."
    end
  end

  def average_distance(segments)
    distance = 0
    segments.each do |segment|
      if !segment.distance.nil?
        distance += segment.distance
      end      
    end
    return distance.div(segments.count)
  end

  def average_speed(segments)
    avgSpeed = 0
    segments.each do |segment|
      if !segment.avgSpeed.nil?
        avgSpeed += segment.avgSpeed
      end
    end
    return avgSpeed.fdiv(segments.count).round(2)

  end

  def modes_count(segments)
    modes = Hash.new(0)
    segments.each do |segment|
      if !segment.transportation.nil?
        modes[segment.transportation.downcase]+=1
      end
    end
    return modes
  end
end

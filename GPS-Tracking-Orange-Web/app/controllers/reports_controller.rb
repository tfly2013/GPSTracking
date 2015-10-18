class ReportsController < ApplicationController
  before_action :authenticate_user!

  # GET /reports
  # GET /reports.json
  def index
    
    if current_user.admin? || current_user.researcher?
       segments = Segment.all
       @average_distance = average_distance(segments)
       @average_speed = average_speed(segments)
       @modes = modes_count(segments)
       datasetItems = @modes.each do |mode, count|
         { 
           chart: {
                caption: "Transportation Mode Statistics",
                xAxisname: "Mode",
                yAxisName: "Count",
                theme: "fint",
                exportEnabled: "1",
              },
           categories: [{
             category: [{ label: mode}]
              }],
           dataset: [{
             seriesname: "Modes",
                data: [{ value: count }]
           }]
         }
         end
       @chart = Fusioncharts::Chart.new({
          width: "600",
          height: "400",
          type: "mscolumn2d",
          renderAt: "chart-container"     
       })
       @chart.dataSource = datasetItems.to_json
      
       render :action => "researcher_index"
    else
       @trips = current_user.trips
       render :action => "user_index"
    end
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

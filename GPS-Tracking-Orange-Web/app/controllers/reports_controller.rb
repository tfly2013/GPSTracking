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
       @chart = Fusioncharts::Chart.new({
          width: "600",
          height: "400",
          type: "mscolumn2d",
          renderAt: "chart-container",
          chart: {
            caption: "Comparison of Quarterly Revenue",
            subCaption: "Harry's SuperMart",
            xAxisname: "Quarter",
            yAxisName: "Amount ($)",
            numberPrefix: "$",
            theme: "fint",
            exportEnabled: "1",
            },
            categories: [{
                  category: [
                      { label: "Q1" },
                      { label: "Q2" },
                      { label: "Q3" },
                      { label: "Q4" }
                  ]
                }],
            dataset: [
                {
                    seriesname: "Previous Year",
                    data: [
                        { value: "10000" },
                        { value: "11500" },
                        { value: "12500" },
                        { value: "15000" }
                    ]
                },
                {
                    seriesname: "Current Year",
                    data: [
                        { value: "25400" },
                        { value: "29800" },
                        { value: "21800" },
                        { value: "26800" }
                    ]
                }
          ] 
       })
      
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

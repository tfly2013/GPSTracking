class ReportsController < ApplicationController
  before_action :authenticate_user!

  # GET /reports
  # GET /reports.json
  def index
    
    if current_user.admin? || current_user.researcher?
       segments = Segment.all
       @average_distance = average_distance(segments)
       @average_speed = average_speed(segments)
       
       #@modes = modes_count(segments)
       @chart = Fusioncharts::Chart.new({
        :height => 400,
        :width => 600,
        :id => 'chart',
        :type => 'column2d',
        :renderAt => 'chart-container', 
        :dataSource => '{
          "chart": {
            "caption": "Transportation Mode Statistics",
            "xAxisName": "Mode",
            "yAxisName": "Count",
            "numberPrefix": "",
            "paletteColors": "#0075c2",
            "bgColor": "#ffffff",
            "borderAlpha": "20",
            "canvasBorderAlpha": "0",
            "usePlotGradientColor": "0",
            "plotBorderAlpha": "10",
            "placevaluesInside": "1",
            "rotatevalues": "1",
            "valueFontColor": "#ffffff",
            "showXAxisLine": "1",
            "xAxisLineColor": "#999999",
            "divlineColor": "#999999",
            "divLineDashed": "1",
            "showAlternateHGridColor": "0",
            "subcaptionFontBold": "0",
            "subcaptionFontSize": "14"
          },
          "data": [{
            "label": "Jan",
            "value": "420000"
          }, {
            "label": "Feb",
            "value": "810000"
          }, {
            "label": "Mar",
            "value": "720000"
          }, {
            "label": "Apr",
            "value": "550000"
          }, {
            "label": "May",
            "value": "910000"
          }, {
            "label": "Jun",
            "value": "510000"
          }, {
            "label": "Jul",
            "value": "680000"
          }, {
            "label": "Aug",
            "value": "620000"
          }, {
            "label": "Sep",
            "value": "610000"
          }, {
            "label": "Oct",
            "value": "490000"
          }, {
            "label": "Nov",
            "value": "900000"
          }, {
            "label": "Dec",
            "value": "730000"
          }]
        }'
       })
       render :action => "researcher_index"
    else
       #trip = Trip.where("user_id = ?", current_user.id)
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

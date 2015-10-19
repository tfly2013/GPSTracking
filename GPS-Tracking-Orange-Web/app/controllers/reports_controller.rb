class ReportsController < ApplicationController
  before_action :authenticate_user!

  # GET /reports
  # GET /reports.json
  def overall
    if current_user.admin? || current_user.researcher?
     @modes = modes_count(Segment.all)
     chartProp = { :caption=> "Transportation Modes Statistics",
      :xAxisname=> "Mode",
      :yAxisName=> "Count",
      :theme=> "fint",
      :exportEnabled=> "1",
      :paletteColors=> "#0075c2",
      :bgColor=> "#ffffff",
      :showBorder=> "0",
      :showCanvasBorder=> "0",
      :usePlotGradientColor=> "0",
      :plotBorderAlpha=> "10",
      :placeValuesInside=> "1",
      :valueFontColor=> "#ffffff",
      :showAxisLines=> "1",
      :axisLineAlpha=> "25",
      :divLineAlpha=> "10",
      :alignCaptionWithCanvas=> "0",
      :showAlternateVGridColor=> "0",
      :captionFontSize=> "14",
      :toolTipColor=> "#ffffff",
      :toolTipBorderThickness=> "0",
      :toolTipBgColor=> "#000000",
      :toolTipBgAlpha=> "80",
      :toolTipBorderRadius=> "2",
      :toolTipPadding=> "5"
    }
    category = []
    data = []
    @modes.each do |mode, count|
      category << {:label => mode}
      data << {:value => count}
    end
    categories = [{:category => category}]
    dataset = [{:seriesname=>"Modes", :data=> data}]
    dataSource = {:chart=> chartProp, :categories=> categories, :dataset => dataset}
    chartData = {:width => 600, :height => 400, :type => "msbar2d", :renderAt => "chart-container", :dataSource => dataSource}
    @chart = Fusioncharts::Chart.new(chartData)
    render :action => "researcher_index"
  end
end

def user
 @trips = current_user.trips
 render :action => "user_index"
end 

def admin_and_researcher_only
  unless current_user.admin? || current_user.researcher?
    redirect_to :back, :alert => "Access denied."
  end
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

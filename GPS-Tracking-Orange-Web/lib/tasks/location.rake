require 'csv.rb'

namespace :location do
	task :insert_locations => :environment do
		filename = './lib/assets/userLocation.csv'
    input = CSV.read(filename)
   	array = []	
    input.each{|line| array << {"longitude"=>line[0],"latitude"=>line[1],"altitude"=>line[2],"haccuracy"=>line[3],"vaccuracy"=>line[4],"timestamp"=>line[5],"speed"=>line[6],"course"=>line[7] }}
    @user = User.find(1)

    @trip = @user.trips.new
    @trip.save
    
    @segment = Segment.new
    @segment.trip = @trip
    @segment.save

    array.each do |line|
    	location = Location.create(user_id: @user.id, latitude: line['latitude'].to_f, longitude: line['longitude'].to_f, accuracy: line['haccuracy'].to_f, time: line['timestamp'], speed: line['speed'])
    	location.segment = @segment
      location.trip = @trip
    	location.save
    end
  end
end

   # @trip = Trip.new
   #  @trip.user = current_user
   #  @segment = Segment.new
   #  @segment.trip = @trip
   #  locations_array.each do |location_params|
   #    @location = Location.new(location_params)
   #    @location.segment = @segment
   #    @location.time = Time.at(location_params[:time] / 1000)
   #    @location.save
   #  end
   #  @trip = convert(@trip)
   #  @trip.segments.each do |segment|
   #    segment.save
   #  end
   #  @trip.save
module ReportsHelper
	def distance(segments)
		distance = 0
		segments.each do |segment|
			if !segment.distance.nil?
				distance += segment.distance
			end      
		end
		return distance
	end

	def average_speed(segments)
		avgSpeed = 0
		count = 0
		segments.each do |segment|
			if !segment.avgSpeed.nil?
				avgSpeed += segment.avgSpeed
				count += 1
			end
		end
		return avgSpeed.fdiv(count).round(2)
	end

	def travel_time(trip)
		startTime = trip.segments.first.locations.where("time Is Not Null").order(:time).first.time
		endTime = trip.segments.last.locations.where("time Is Not Null").order(:time).last.time     	  			
		return Time.at((endTime - startTime).to_i.abs).utc.strftime "%H:%M:%S"
	rescue
		return "Unknown"
	end
end

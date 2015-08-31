module TripsHelper

	def convert(locations)
		input = locations.map { |l| [l.latitude, l.longitude] }
		dbscan = DBSCAN( input, :epsilon => 0.01, :min_points => 4, :distance => :haversine_distance2, :labels => locations )
		
		loose = dbscan.clusters.first.last.map {|point| point.label }
		transfer_zone = dbscan.clusters.drop(1).map {|cluster| cluster.last.map {|point| point.label }}
	end
end

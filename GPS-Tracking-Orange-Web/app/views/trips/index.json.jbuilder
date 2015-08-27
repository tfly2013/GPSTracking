json.array!(@trips) do |trip|
  json.extract! trip, :id, :startLocation, :endLocation, :startTime, :endTime, :user_id
  json.url trip_url(trip, format: :json)
end

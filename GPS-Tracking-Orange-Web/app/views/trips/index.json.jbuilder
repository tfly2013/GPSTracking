json.array!(@trips) do |trip|
  json.extract! trip, :id, :startLocation, :endLocation, :user_id
  json.url trip_url(trip, format: :json)
end

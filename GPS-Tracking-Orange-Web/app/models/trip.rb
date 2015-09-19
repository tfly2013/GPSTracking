class Trip < ActiveRecord::Base
  belongs_to :user
  has_many :segments
  has_many :locations, :through => :segments


  def snap_to_road
    all = self.locations.to_ary
    while !all.empty?
      locations = all.shift(100)
      path = []
      locations.each do |location|
        path << location.latitude.to_s + "," + location.longitude.to_s
      end
      service_url = "https://roads.googleapis.com/v1/snapToRoads"
      uri = URI.parse(service_url)
      params = {:key => "AIzaSyA-10-w06yl2bTDNkIPGT0sD52X32pAyZE", :path => path.join("|")}
      uri.query = URI.encode_www_form(params)
      request = Net::HTTP::Get.new(uri)
      request["Accept"] = "application/json"
      connection = Net::HTTP.new(uri.host, uri.port)
      connection.use_ssl = true
      connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
      response = connection.start {|http| http.request(request) }
      data = JSON.parse(response.body)

      Trip.transaction do
        i = 0
        data["snappedPoints"].each do |point|
          index = point["originalIndex"]
          while index > i
            locations[i].destroy
            i+=1
          end
          locations[index].latitude = point["location"]["latitude"]
          locations[index].longitude = point["location"]["longitude"]
          locations[index].save!
          i+=1
        end
      end
    end
  end
  handle_asynchronously :snap_to_road

  # Algorithm
  def convert
    return self
  end
end

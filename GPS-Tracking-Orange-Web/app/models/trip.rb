class Trip < ActiveRecord::Base
  belongs_to :user
  has_many :segments
  has_many :locations, :through => :segments 

  LOW_SPEED = 0.83
  WALKING = 2.22
  BYCYCLE = 8.33
  TRAM = 11.11
  BUS = 22.22
  TRAIN = 25.2
  CAR = 27.7

  WALKING_AVG = 1.1
  BYCYCLE_AVG = 4.16
  TRAM_AVG = 4.44
  BUS_AVG = 11.11
  # TRAIN AND CAR AVG SPEED NEED MORE EFFORTS TO ADJUST
  TRAIN_AVG = 16.66
  CAR_AVG = 16.66

  TRANSPORTATIONS = ["walking", "bicycle", "tram", "bus", "train", "car", "unknown"]

  def SegmentsReorgnize()
    @trip = self
    locations = []
    oldSegments = []
    @trip.segments.order(:order).each{|segment|oldSegments << segment}
    @trip.locations.order(:order).each{|location|locations << location}
    currentSegment = nil
    order = 0
    prevLocation = nil
    # step1. difference segments by moving or not
    locations.each do |location|
      if location.speed > 0 
        locationStatus = "moving"
      else
        locationStatus = "stopping"
      end
      # at first
      if currentSegment.nil?
        # generate a new segment
        result = genSegment(order, @trip, location, locationStatus)
        order = result["order"]
        currentSegment = result["segment"]
      else
        # currentSegment and current location have same transportation
        if currentSegment.transportation != locationStatus
          # finish currentSegment
          endSegment(currentSegment)
          # generate a new segment
          result = genSegment(order, @trip, location, locationStatus)
          order = result["order"]
          currentSegment = result["segment"]
        end
      end

      # if currentSegment is new
      if currentSegment.locations.count == 0
        currentSegment.startTime = location.time
        currentSegment.save
      else
        currentSegment.distance += distanceBetween(prevLocation, location)
      end      
      # link location and segment
      location.segment = currentSegment
      location.save
      # endTime, highest speed
      currentSegment.endTime = location.time
      if currentSegment.highestSpeed < location.speed
        currentSegment.highestSpeed = location.speed
      end
      prevLocation = location
    end
    endSegment(currentSegment)
    # after reorg segments, delete old segments
    oldSegments.each{|segment|segment.delete}
    # step2. split all segments by meaningful and meaningless
    #      . adjust meaningful segments by giving futher transportation analysis
    # Following are the rules for meaningless segments.
    # => no valid speed for any points within this segment.
    # => number of points < 10 and endTime - startTime < 10(s)
    # => distance < 10(m)
    # => highestSpeed < 0.83(m/s), means 3km/h, this is the buttom line for normal walking.
    # => averageSpeed < 0.83(m/s)
    oldSegments = []
    currentSegment = nil
    order = 0
    prevSegmentStatus = nil
    @trip.segments.order(:order).each do |segment|
      oldSegments << segment
      # evaluate segment
      if currentSegment.nil?
        result = cloneSegment(order, segment)
        order = result["order"]
        currentSegment = result["segment"]
      else
        if currentSegment.transportation == segment.transportation
          # merge continuous meaningless segments
          if currentSegment.transportation == "meaningless"
            mergeSegment(currentSegment, segment)
          end
        else
          result = cloneSegment(order, segment)
          order = result["order"]
          currentSegment = result["segment"]
        end
      end
    end
    oldSegments.each{|segment|segment.delete}
  end

  def mergeSegment(segment1, segment2)
    segment2.locations.each do |location|
      location.segment = segment1
      location.save
    end
    segment1.distance += segment2.distance
    segment1.highestSpeed = [segment1.highestSpeed,segment2.highestSpeed].max
    segment1.endTime = segment2.endTime
    if segment1.startTime != segment1.endTime
      segment1.avgSpeed = segment1.distance.to_f/(segment1.endTime.to_i - segment1.startTime.to_i).to_f
    else
      segment1.avgSpeed = 0
    end
    segment1.save
  end

  def endSegment(currentSegment)
    # Following are the rules for specific transportation.
    # => Transportation   | speed range | averageSpeed 
    # => walking          | 0.83 ~ 1.94 | 1.1
    # => bicycle          | 0.83 ~ 8.33 | 4.16
    # => tram             | 0.83 ~ 11.1 | 4.44
    # => bus              | 0.83 ~ 22.22| 11.1
    # => car              | 0.83 ~ ???  | ???
    # => train            | 0.83 ~ 27.7 | ???
    #TODO calculate avgSpeed and transportation
    if currentSegment.startTime != currentSegment.endTime
      currentSegment.avgSpeed = currentSegment.distance.to_f/(currentSegment.endTime.to_i - currentSegment.startTime.to_i).to_f
    else
      currentSegment.avgSpeed = 0
    end

    if currentSegment.transportation == "stopping" || currentSegment.locations.count < 10 || (currentSegment.endTime.to_i - currentSegment.startTime.to_i) < 10 || currentSegment.distance < 20 || currentSegment.highestSpeed <= LOW_SPEED || currentSegment.avgSpeed <= LOW_SPEED
      currentSegment.transportation = "meaningless"
    else
      averageResult = transFromAVG(currentSegment.avgSpeed)
      highResult = transFromHigh(currentSegment.highestSpeed)
      if averageResult["transportation"].in?(highResult["transportation"])
        currentSegment.transportation = averageResult["transportation"]
      else
        currentSegment.transportation = highResult["transportation"][0]
      end
    end
    currentSegment.save
  end

  def transFromAVG(avgSpeed)
    avgScore = 0
    # average speed
    if avgSpeed > WALKING_AVG
      avgScore += 1
    end
    if avgSpeed > BYCYCLE_AVG
      avgScore += 1
    end
    if avgSpeed > TRAM_AVG
      avgScore += 1
    end
    if avgSpeed > BUS_AVG
      avgScore += 1
    end
    if avgSpeed > TRAIN_AVG
      avgScore += 1
    end
    if avgSpeed > CAR_AVG
      avgScore += 1
    end

    case avgScore
    when 0
      return {"value"=>avgScore, "transportation" => "walking"}
    when 1
      return {"value"=>avgScore, "transportation" => (avgSpeed - WALKING_AVG)>(BYCYCLE_AVG - avgSpeed) ? "bicycle" : "walking"}
    when 2
      return {"value"=>avgScore, "transportation" => (avgSpeed - BYCYCLE_AVG)>(TRAM_AVG - avgSpeed) ? "tram" : "bicycle"}
    when 3
      return {"value"=>avgScore, "transportation" => (avgSpeed - TRAM_AVG)>(BUS_AVG - avgSpeed) ? "bus" : "tram"}
    when 4
      return {"value"=>avgScore, "transportation" => (avgSpeed - BUS_AVG)>(TRAIN_AVG - avgSpeed) ? "train" : "bus"}
    when 5
      return {"value"=>avgScore, "transportation" => (avgSpeed - TRAIN_AVG)>(CAR_AVG - avgSpeed) ? "car" : "train"}
    when 6
      return {"value"=>avgScore, "transportation" => "unknow"}
    end    
  end

  def transFromHigh(highSpeed)
    highScore = 0
    # highest speed
    if highSpeed > WALKING
      highScore += 1
    end
    if highSpeed > BYCYCLE
      highScore += 1
    end
    if highSpeed > TRAM
      highScore += 1
    end
    if highSpeed > BUS
      highScore += 1
    end
    if highSpeed > TRAIN
      highScore += 1
    end
    if highSpeed > CAR
      highScore += 1
    end
    trans=[]
    if highScore == 0
      trans << TRANSPORTATIONS[highScore]
    else
      highScore.times{|i|trans << TRANSPORTATIONS[i]}
    end
    return {"value"=>highScore, "transportation"=>trans}
  end

  def cloneSegment(order, segment)
    currentSegment = segment.dup
    currentSegment.order = order
    currentSegment.save
    segment.locations.each do |location|
      location.segment = currentSegment
      location.save
    end
    return {"order"=>order+1, "segment"=>currentSegment}
  end

  def genSegment(order, trip, location, locationStatus)
    # a new segment starts
    currentSegment = trip.segments.new
    # order
    currentSegment.order = order
    # transportation and start end time
    currentSegment.transportation = locationStatus
    currentSegment.distance = 0
    currentSegment.highestSpeed = 0
    currentSegment.avgSpeed = 0
    currentSegment.save
    return {"order"=>order+1, "segment"=>currentSegment}
  end

  def distanceBetween(location1, location2)
    dlon = (location2.longitude - location1.longitude) * Math::PI / 180
    dlat = (location2.latitude - location1.latitude) * Math::PI / 180

    lat1 = location1.latitude * Math::PI / 180
    lat2 = location2.latitude * Math::PI / 180

    a = Math.sin(dlat/2)**2 + Math.cos(lat1) * Math.cos(lat2) * Math.sin(dlon/2)**2
    c = 2 * Math.asin(Math.sqrt(a))
    r = 6371000
    distance = r * c
    return distance
  end
end
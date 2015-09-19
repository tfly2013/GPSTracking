class Trip < ActiveRecord::Base
  belongs_to :user
  has_many :segments
  has_many :locations, :through => :segments 

  def SegmentsReorgnize()
    @trip = self
    locations = []
    oldSegments = []
    @trip.segments.order(:order).each do |segment|
      oldSegments << segment
      segment.locations.order(:order).each{|location|locations << location}
    end
    currentSegment = nil
    order = 0
    # step1. difference segments by moving or not
    locations.each do |location|
      if location.speed == 0
        locationStatus = "stopping"
      elsif location.speed == -1
        locationStatus = "unclear"
      elsif location.speed > 0
        locationStatus = "moving"
      else
        locationStatus = "fuck"
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
        currentSegment.distance += distanceBetween(currentSegment.locations.order(:order).last, location)
      end      
      # link location and segment
      location.segment = currentSegment
      location.save
      # endTime, highest speed
      currentSegment.endTime = location.time
      if currentSegment.highestSpeed < location.speed
        currentSegment.highestSpeed = location.speed
      end
    end
    # after reorg segments, delete old segments
    oldSegments.each{|segment|segment.delete}

    # step2. merge continuous stopping/unclear/fuck segments
    @trip.segments.order(:order).each do |segment|

    end
    # step3. adjust moving segments by giving futher transportation analysis
  end

  def mergeSegment

  end

  def endSegment(currentSegment)
    #TODO calculate avgSpeed and transportation
    if currentSegment.startTime != currentSegment.endTime
      currentSegment.avgSpeed = currentSegment.distance.div(currentSegment.endTime - currentSegment.startTime)
    else
      currentSegment.avgSpeed = 0
    end
    currentSegment.save
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
    dlon = location2.longitude - location1.longitude
    dlat = location2.latitude - location1.latitude

    a = Math.sin(dlat/2)**2 + Math.cos(location1.latitude) * Math.cos(location2.latitude) * Math.sin(dlon/2)**2
    c = 2 * Math.asin(Math.sqrt(a))
    distance = 6272.795 * c
    return distance
  end


   #constants
  # STOP_DISTANCE = 0.5
  # SPEED_DIFFERENCE = 5
  # TRANSPORATION_TIME = 10
  # def segmentsReorginize
  #   # variables
  #   locations = []
  #   segments = []
  #   currentSegment = []
  #   tempStoppingSegment = []
  #   oldSegments = []
  #   prevLocation = nil
  #   unclear = false
  #   speedAmount = 0
  #   speedRecorder = 0
  #   avgSpeed4PrevSegment = 0
  #   avgSpeed4CurSegment = 0
  #   stoppingTime = 0
  #   # put all locations into an array
  #   self.segments.each{|segment|oldSegments << segment}
  #   self.locations.each{|location| locations << location}
  #   locations.each do |location|
  #     if prevLocation.nil?
  #       prevLocation = location
  #       currentSegment << location
  #       #speedAmount += location.speed
  #     else
  #       speedAmount += speed(prevLocation, location)
  #       #speedAmount += location.speed
  #       # ?????
  #       avgSpeed4CurSegment = speedAmount.fdiv(currentSegment.length)
  #       # stop
  #       if moveDistance(prevLocation, location) <= STOP_DISTANCE
  #         if stoppingTime == 0
  #           stoppingTime = prevLocation.time
  #           speedRecorder = avgSpeed4CurSegment
  #         end
  #         # ?????
  #         if unclear
  #           # transportation has changed
  #           if avgSpeed4CurSegment - avgSpeed4PrevSegment > SPEED_DIFFERENCE
  #             segments << currentSegment
  #             currentSegment.clear
  #             tempStoppingSegment.each{|location|currentSegment << location}
  #             tempStoppingSegment.clear
  #           else
  #             # transportation has not changed
  #             tempStoppingSegment.each{|location|currentSegment << location}
  #             tempStoppingSegment.clear
  #           end
  #           unclear = false
  #         end
  #         tempStoppingSegment << location
  #       # moving
  #       else
  #         # stop for a long time, segment ends, discard locations during stop time
  #         if stoppingTime != 0 && location.time - stoppingTime >= TRANSPORATION_TIME
  #           segments << currentSegment
  #           currentSegment.clear
  #           currentSegment << location 
  #           tempStoppingSegment.clear
  #           #????? stoppingTime still not equals zero
  #         elsif stoppingTime != 0 && location.time - stoppingTime < TRANSPORATION_TIME
  #           # stop for a short time, tempStoppingSegment starts
  #           unclear = true
  #           tempStoppingSegment << location
  #           avgSpeed4PrevSegment = speedRecorder
  #           avgSpeed4CurSegment = 0
  #           stoppingTime = 0
  #         else
  #           if unclear
  #             tempStoppingSegment << location
  #           else
  #             currentSegment << location
  #           end
  #         end
  #       end
  #     end
  #     prevLocation = location       
  #   end
  #   segments.each do |segment|
  #     logger.debug (segment.id)
  #     @segment = self.segments.new
  #     @segment.trip = self
  #     @segment.save
  #     segment.each do |location|
  #       location.segment = @segment
  #       location.save
  #     end
  #   end
  #   oldSegments.each{|segment|segment.delete}
  # end

  # def speed(prev, curr)
  #   return moveDistance(prev, curr).fdiv(curr.time - prev.time)
  # end
end
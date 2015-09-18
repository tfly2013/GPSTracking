class Trip < ActiveRecord::Base
  belongs_to :user
  has_many :segments
  has_many :locations, :through => :segments   
  #constants
  STOP_DISTANCE = 0.5
  SPEED_DIFFERENCE = 5
  TRANSPORATION_TIME = 10
  def segmentsReorginize
    # variables
  	locations = []
  	segments = []
    currentSegment = []
    tempStoppingSegment = []
    oldSegments = []
    prevLocation = nil
    unclear = false
    speedAmount = 0
    speedRecorder = 0
    avgSpeed4PrevSegment = 0
    avgSpeed4CurSegment = 0
    stoppingTime = 0
  	# put all locations into an array
  	self.segments.each{|segment|oldSegments << segment}
    self.locations.each{|location| locations << location}
    locations.each do |location|
      if prevLocation.nil?
        prevLocation = location
        currentSegment << location
        #speedAmount += location.speed
      else
        speedAmount += speed(prevLocation, location)
        #speedAmount += location.speed
        # ?????
        avgSpeed4CurSegment = speedAmount.fdiv(currentSegment.length)
        # stop
        if moveDistance(prevLocation, location) <= STOP_DISTANCE
          if stoppingTime == 0
            stoppingTime = prevLocation.time
            speedRecorder = avgSpeed4CurSegment
          end
          # ?????
          if unclear
            # transportation has changed
            if avgSpeed4CurSegment - avgSpeed4PrevSegment > SPEED_DIFFERENCE
              segments << currentSegment
              currentSegment.clear
              tempStoppingSegment.each{|location|currentSegment << location}
              tempStoppingSegment.clear
            else
              # transportation has not changed
              tempStoppingSegment.each{|location|currentSegment << location}
              tempStoppingSegment.clear
            end
            unclear = false
          end
          tempStoppingSegment << location
        # moving
        else
          # stop for a long time, segment ends, discard locations during stop time
          if stoppingTime != 0 && location.time - stoppingTime >= TRANSPORATION_TIME
            segments << currentSegment
            currentSegment.clear
            currentSegment << location 
            tempStoppingSegment.clear
            #????? stoppingTime still not equals zero
          elsif stoppingTime != 0 && location.time - stoppingTime < TRANSPORATION_TIME
            # stop for a short time, tempStoppingSegment starts
            unclear = true
            tempStoppingSegment << location
            avgSpeed4PrevSegment = speedRecorder
            avgSpeed4CurSegment = 0
            stoppingTime = 0
          else
            if unclear
              tempStoppingSegment << location
            else
              currentSegment << location
            end
          end
        end
      end
      prevLocation = location       
    end
    segments.each do |segment|
      logger.debug (segment.id)
      @segment = self.segments.new
      @segment.trip = self
      @segment.save
      segment.each do |location|
        location.segment = @segment
        location.save
      end
    end
    oldSegments.each{|segment|segment.delete}
  end

  def speed(prev, curr)
    return moveDistance(prev, curr).fdiv(curr.time - prev.time)
  end

  def moveDistance(location1, location2)
    dlon = location2.longitude - location1.longitude
    dlat = location2.latitude - location1.latitude

    a = Math.sin(dlat/2)**2 + Math.cos(location1.latitude) * Math.cos(location2.latitude) * Math.sin(dlon/2)**2
    c = 2 * Math.asin(Math.sqrt(a))
    distance = 6272.795 * c
    return distance.div(1000)

  end
end

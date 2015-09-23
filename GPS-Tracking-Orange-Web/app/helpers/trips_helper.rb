module TripsHelper

  def convert(locatons)
  	trip = Array.new
  	segment = Array.new
  	tempStoppingSegment = Array.new
  	prev = null
  	unclear = false
  	allSpeed = 0
  	speedRecorder = 0
  	avgSpeed4PrevSegment = 0
  	avgSpeed4CurSegment = 0
  	stoppingTime = 0
    for location in locations
    	if prev == null
    		prev = location
    		segment << location
    		next
    	else
    		allSpeed += speed(prev, location)
    		avgSpeed4CurSegment = allSpeed.fdiv(segment.length)
    		if moveDistance(prev, location) == 0 #Concept only, if for some reason the user stopped, flag it
    			if stoppingTime == 0
    				stoppingTime = prev.time
    				speedRecorder = avgSpeed4CurSegment
    			end
    			if unclear
    				if avgSpeed4CurSegment - avgSpeed4PrevSegment > 10
              # the diff between the speeds are greater than 10
    					#Has changed transportation
    					trip << segment
    					segment.clear
    					segment = tempStoppingSegment
    					tempStoppingSegment.clear
    					#getTransportationMethod(avgSpeed4PrevSegment)

    				else
    					#Has not changed transportation
    					segment += tempStoppingSegment
    					tempStoppingSegment.clear
    				end
    				unclear = false
    			end
    			tempStoppingSegment << location


    		# moveDistance > 0
    		else
    			if stoppingTime != 0 && location.time - stoppingTime > 5 #Concept Only, user starts moving from stopping and stopping time is greater than 5 mins
    				trip << segment
    				segment.clear
    				segment << location
    				tempStoppingSegment.clear
    				#getTransportationMethod(speedRecorder)

    				avgSpeed4PrevSegment = speedRecorder
    				avgSpeed4CurSegment = 0
    				stoppingTime = 0
            # ? stop for 5 mins but dont know if the transportation changes
    			elsif stoppingTime != 0 && location.time - stoppingTime < 5 #Concept Only, user starts moving from stopping and stopping time is less than 5 mins
    				unclear = true
    				tempStoppingSegment << location
    				avgSpeed4PrevSegment = speedRecorder
    				avgSpeed4CurSegment = 0
    				stoppingTime = 0
    			else	#Moving normally
    				if unclear
    					tempStoppingSegment << location
    				else
    					segment << location
    				end
    			end
    		end
    	end
    	prev = location
    end

    # >>>>>>>>>>>>>>>>>>>>>>>>>>
    segment << location
    trip << segment
    return trip

  end
  
  #Haversine formula
  def moveDistance(location1, location2)
  	dlon = location2.lon - location1.lon
  	dlat = location2.lat - location1.lat

  	a = Math.sin(dlat/2)**2 + Math.cos(location1.lat) * Math.cos(location2.lat) * Math.sin(dlon/2)**2
  	c = 2 * Math.asin(Math.sqrt(a))
  	distance = 6272.795 * c
  	return distance
  end

  def speed(location1, location2)
  	return moveDistance(location1, location2).fdiv(location2.time - location1.time)
  end	

  def getTransportationMethod(averageSpeed)
  	if averageSpeed <= 5 #Concept only, if average speed is less than 5km/h
    	#Set transportation method to walking
    elsif averageSpeed > 5 && averageSpeed <= 20 #Concept only, if average speed is greater than 5km/h but less tham 20km/h
    	#Set transportation method to cycling
    elsif averageSpeed > 20 #Concept only, if average speed is greater than 20km/h
    	#Set transportation method to motor vehicle
    end
  end
end
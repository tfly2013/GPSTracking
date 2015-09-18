// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
debugger;

var colours = ["red","orange","green","blue","purple"];
var zones = [];
var segments = [];
var selected;
var map;

/***
* Initialize map
*/
function initMap(){
	map = new google.maps.Map(document.getElementById('map'), {
		zoom: 12,
		center: {lat: -37.7962972, lng: 144.961397}
	});
	zones = [];
	segments = [];
	map.controls[google.maps.ControlPosition.RIGHT_TOP].push(
		document.getElementById('map-control'));
	google.maps.event.addListenerOnce(map,"projection_changed", function() {
		phaseTrip();
		zoomToTrip();
		addSegmentsToAccordion();		
		//testMarkers();
		drawSegments();
		drawZones();	
		snapZonesToSegments();
	});
}

/*** 
* Phase locations in trip into google map LatLng object
*/
function phaseTrip(){		
	if (trip.length == 0)
		return;	
	for (var i = 0; i < trip.length ; i++){
		var segment = [];
		segment.id = trip[i].id;
		segment.transportation = trip[i].transportation;
		for (var j = 0; j < trip[i].locations.length; j++){
			var latlng = new google.maps.LatLng(
				trip[i].locations[j].lat,trip[i].locations[j].lng);
			latlng.id = trip[i].locations[j].id;
			if (j == 0 && i > 0){
				trip[i-1].push(latlng);
			}
			segment.push(latlng);
		}
		trip[i] = segment;
	}
}

/*** 
* Zoom the map to show the trip
*/
function zoomToTrip(){	
	var bounds = new google.maps.LatLngBounds();
	for (var i = 0; i < trip.length ; i++){
		for (var j = 0; j < trip[i].length; j++)
			bounds.extend(trip[i][j]);
	}
	map.fitBounds(bounds);
}

function addSegmentsToAccordion(){
	for (var i = 0; i < trip.length ; i++){
		$("[title]").tooltip();
		$("#accordion")
		.append("<h3 id="+ i +">Segment " + (i + 1) + "</h3>" +
			"<div><label class='control-label'>Transportation</label>" +
			"<input type='text' id=transportation-"+ i +
			" class='form-control' value="+ trip[i].transportation +" /></div>");
		$("#" + i).draggable({
			containment: "parent", 
			revert: "invalid", 
			helper: "clone"
		});
		$("#" + i).droppable({
			accept: "#" + (i - 1) +", #" + (i + 1),
			activeClass: "segment-drop-active",
			hoverClass: "segment-drop-hover"
		});
	}
	$("#accordion").accordion({
		collapsible: true,
		active: false,
		heightStyle: "content",
		activate: function( event, ui ) {
			var id;
			if (ui.newHeader.length > 0)
				id = ui.newHeader[0].id;			
			selectSegment(id);
		}
	});
}

function selectSegment(id){
	if (id == null){
		selected = null;
		for (var i = 0; i < segments.length ; i++)
			segments[i].setOptions({
				strokeColor: colours[i%colours.length] 
			});		
	}
	else{
		for (var i = 0; i < segments.length ; i++)
			segments[i].setOptions({
				strokeColor: '#C8C8C8'
			});		
		selected = segments[id];
		selected.setOptions({
			strokeColor: colours[id%colours.length]
		});
	}
}

/*** 
* Draw each segement (polyline)
*/
function drawSegments() {	
	for (var i = 0; i < trip.length; i++){
		segment = new google.maps.Polyline({
			path: trip[i],
			strokeColor: colours[i%colours.length],
			strokeWeight: 5
		});
		segment.setMap(map);
		segment.segId = trip[i].id;
		segment.id = i;
		segments.push(segment);
	}
}

function testMarkers(){
	for (var i = 0; i < trip.length ; i++){
		for (var j = 0; j < trip[i].length; j++){
			var marker = new google.maps.Marker({
				position: trip[i][j],
				opacity: 0.3
			});
			marker.setMap(map);
			marker.pid = trip[i][j].id;
			google.maps.event.addListener(marker, "click", function(){
				console.log(this.pid);
			});
		}
	}
}

/*** 
* Draw each transfer zones (marker)
*/
function drawZones(){
	// The start position
	var zone = new google.maps.Marker({
		position: trip[0][0]
	});
	zone.setMap(map);	
	zone.id = 0;	
	zone.segAfter = segments[0];
	zone.fixed = true;	
	zones.push(zone);
	// Transfer zones
	for (var i = 1; i < trip.length; i++){
		var zone = new google.maps.Marker({
			position: trip[i][0],
			draggable: true
		});
		zone.setMap(map);	
		zone.id = i;	
		zone.segAfter = segments[i];
		zone.segBefore = segments[i - 1];
		zone.fixed = false;
		zones.push(zone);
	}
	// The end position
	var i = trip.length - 1;
	var j = trip[i].length -1;
	var zone = new google.maps.Marker({
		position: trip[i][j]
	});
	zone.setMap(map);	
	zone.id = i;	
	zone.segBefore = segments[i];
	zone.fixed = true;
	zones.push(zone);	
}

/** snap zones to segments, make zones can only move along segments
*/
function snapZonesToSegments(){
	for (var i = 1; i < zones.length - 1; i++){
		var zone = zones[i];
		var before = zone.segBefore.getPath().getArray();
		var after = zone.segAfter.getPath().getArray();
		// the moving range of a zone is segment before plus segment after
		merged = new google.maps.Polyline({
			path: before.concat(after)
		});
		zone.str = new SnapToRoute(map, zone, merged);
		google.maps.event.addListener(zone, "drag", function(){
			updateSegments(this);
		});
		google.maps.event.addListener(zone, "dragend", function(){
			updateSegments(this);
		});
	}
}

/** Update segment after zone has changed position
*/
function updateSegments(zone){
	// zone's current position is between point[n] and point[n-1] along the line that it snapped to
	var n = zone.str.getPointPosition();
	var segment;
	// move to segment before or after
	var before = false;
	if (n > zone.segBefore.getPath().length){
		// move after, determine the real n on segAfter
		n-= zone.segBefore.getPath().length;
		segment = zone.segAfter;
	}
	else{
		segment = zone.segBefore;
		before = true;
	}
	var id = segment.id;
	var latlng = zone.getPosition();
	var removed;
	if (before){
		// remove the last point of segBefore (which is same as the first point of segAfter)
		trip[id].pop();
		// rmeove points from the end of segBefore, add current zone point at last
		removed = trip[id].splice(n, trip[id].length-n, latlng);
		// remove the first point of segAfter, if it's a new point(no id), 
		// which mean it was inserted by last zone move
		if (trip[id+1][0].id == null){
			trip[id+1].shift();
		}
		// add removed points to segAfter
		for (var i = removed.length - 1; i >= 0; i--)
			trip[id+1].unshift(removed[i]);
		// insert current zone point at the beginning of segAfter
		trip[id+1].unshift(latlng);
		// update both segments
		segments[id].setPath(trip[id]);
		segments[id+1].setPath(trip[id+1]);
	}
	else{
		// similar to before
		trip[id].shift();
		removed = trip[id].splice(0, n, latlng);
		if (trip[id-1][trip[id-1].length - 1].id == null){
			trip[id-1].pop();
		}
		for (var i = 0; i < removed.length; i++)
			trip[id-1].push(removed[i]);
		trip[id-1].push(latlng);		
		segments[id].setPath(trip[id]);
		segments[id-1].setPath(trip[id-1]);
	}

	// update the moving range of zone before and zone after
	updateStr(zones[zone.id - 1]);
	updateStr(zones[zone.id + 1]);
}

/** Update snap to route object to update the moving range of a zone
*/
function updateStr(zone){
	if (zone.fixed)
		return;	
	var before = zone.segBefore.getPath().getArray();
	var after = zone.segAfter.getPath().getArray();
	zone.str.updateLine(before.concat(after));
}


function saveTrip(){
	var tripData = {};
	var segments = [];
	for (var i = 0; i < trip.length; i++){
		var segment = {};
		segment.id = trip[i].id;
		segment.transportation = $("#transportation-" + i)[0].value;
		segment.order = i + 1;
		var locations = []
		// The last point is the repeat of the first point of next segment
		for (var j = 0; j < trip[i].length - 1; j++){
			var location = {};
			if (trip[i][j].id != null)
				location.id = trip[i][j].id;
			location.latitude = trip[i][j].lat();
			location.longitude = trip[i][j].lng();
			location.order = (i + 1) * (j + 1);
			locations.push(location);
		}
		segment.locations_attributes = locations;
		segments.push(segment);
	}
	tripData.segments_attributes = segments;
	$.ajax({
		type: "PATCH",
		url: tripUrl,
		data: JSON.stringify({trip: tripData}),
		contentType: "application/json",
		dataType: "json",
		success: function(){
			alert("Trip updated successfully.");
			window.location.replace(tripUrl);
		},
		error: function(){
			alert("Something wrong happened, please try again.");
			window.location.replace(tripUrl);
		}
	});
}


/** 
 * Modified Snap to route library
 *
 * @constructor
 * @desc Creates a new SnapToRoute that will snap the marker to the route.
 * @param {GMap2} map Map to assign listeners to.
 * @param {GMarker} marker Marker to move along the route.
 * @param {GPolyline} polyline The line the marker should snap to.
 */
 function SnapToRoute(map, marker, polyline) {
 	this.routePixels_ = [];
 	this.normalProj_ = map.getProjection();
 	this.map_ = map;
 	this.marker_ = marker;
 	this.polyline_ = polyline;

 	this.init_();
 }

/**
 * Initialize the objects.
 * @private
 */ 
 SnapToRoute.prototype.init_ = function () {
 	this.loadLineData_();
 	this.loadMapListener_();
 };

/**
 * Change the marker and/or polyline used by the class.
 * @param {GMarker} marker Optional marker to move along the route, 
 *   or null if you do not want to change that target.
 * @param {GPolyline} polyline Optional line to snap to, 
 *   or null if you do not want to change that target.
 */
 SnapToRoute.prototype.updateTargets = function (marker, polyline) {
 	this.marker_ = marker || this.marker_;
 	this.polyline_ = polyline || this.polyline_;
 	this.loadLineData_();
 };

/**
 * update the polyline data.
 */
 SnapToRoute.prototype.updateLine = function (path) {
 	this.polyline_.setPath(path);
 	this.loadLineData_();
 };

/**
 * Set up map listeners to calculate and update the marker position.
 * @private
 */
 SnapToRoute.prototype.loadMapListener_ = function () {
 	var me = this;

 	google.maps.event.addListener(me.marker_, "dragend", function (evt) {
 		me.updateMarkerLocation_(evt.latLng);
 	});

 	google.maps.event.addListener(me.marker_, "drag", function (evt) {
 		me.updateMarkerLocation_(evt.latLng);
 	});

 	google.maps.event.addListener(me.map_, "zoomend", function (evt) {
 		me.loadLineData_();
 	});
 };

/**
 * Load route pixels into array for calculations. 
 * This needs to be calculated whenever zoom changes 
 * @private
 */
 SnapToRoute.prototype.loadLineData_ = function () {
 	var zoom = this.map_.getZoom();
 	this.routePixels_ = [];
 	var path = this.polyline_.getPath();
 	for (var i = 0; i < path.getLength(); i++) {
 		var Px = this.normalProj_.fromLatLngToPoint(path.getAt(i));
 		this.routePixels_.push(Px);
 	}
 };

/**
 * Handle the move listener output and move the given marker.
 * @param {GLatLng} mouseLatLng
 * @private
 */
 SnapToRoute.prototype.updateMarkerLocation_ = function (mouseLatLng) {
 	var markerLatLng = this.getClosestLatLng(mouseLatLng);
 	this.marker_.setPosition(markerLatLng);
 };

/**
 * Calculate closest lat/lng on the polyline to a test lat/lng.
 * @param {GLatLng} latlng The coordinate to test.
 * @return {GLatLng} The closest coordinate.
 */
 SnapToRoute.prototype.getClosestLatLng = function (latlng) {
 	var r = this.distanceToLines_(latlng);
 	return this.normalProj_.fromPointToLatLng(new google.maps.Point(r.x, r.y));
 };

/** @return the nearest segment which indicates the position of marker
*/
SnapToRoute.prototype.getPointPosition = function () {
	latlng = this.marker_.getPosition();
	var r = this.distanceToLines_(latlng);
	return r.i;
}

/**
 * Gets test pixel and then calls fundamental algorithm.
 * @param {GLatLng} mouseLatLng
 * @private
 */
 SnapToRoute.prototype.distanceToLines_ = function (mouseLatLng) {
 	var zoom = this.map_.getZoom();
 	var mousePx = this.normalProj_.fromLatLngToPoint(mouseLatLng);
 	var routePixels_ = this.routePixels_;
 	return this.getClosestPointOnLines_(mousePx, routePixels_);
 };

/**
 * Static function. Find point on lines nearest test point
 * test point pXy with properties .x and .y
 * lines defined by array aXys with nodes having properties .x and .y 
 * return is object with .x and .y properties and property i indicating nearest segment in aXys 
 * and property from the fractional distance of the returned point from aXy[i-1]
 * and property to the fractional distance of the returned point from aXy[i]    
 * @param {Object} pXy
 * @param {Array<Point>} aXys
 * @private
 */
 SnapToRoute.prototype.getClosestPointOnLines_ = function (pXy, aXys) {
 	var minDist;
 	var to;
 	var from;
 	var x;
 	var y;
 	var i;
 	var dist;

 	if (aXys.length > 1) {
 		for (var n = 1; n < aXys.length; n++) {
 			if (aXys[n].x !== aXys[n - 1].x) {
 				var a = (aXys[n].y - aXys[n - 1].y) / (aXys[n].x - aXys[n - 1].x);
 				var b = aXys[n].y - a * aXys[n].x;
 				dist = Math.abs(a * pXy.x + b - pXy.y) / Math.sqrt(a * a + 1);
 			} else {
 				dist = Math.abs(pXy.x - aXys[n].x);
 			}

 			var rl2 = Math.pow(aXys[n].y - aXys[n - 1].y, 2) + Math.pow(aXys[n].x - aXys[n - 1].x, 2);
 			var ln2 = Math.pow(aXys[n].y - pXy.y, 2) + Math.pow(aXys[n].x - pXy.x, 2);
 			var lnm12 = Math.pow(aXys[n - 1].y - pXy.y, 2) + Math.pow(aXys[n - 1].x - pXy.x, 2);
 			var dist2 = Math.pow(dist, 2);
 			var calcrl2 = ln2 - dist2 + lnm12 - dist2;
 			if (calcrl2 > rl2) {
 				dist = Math.sqrt(Math.min(ln2, lnm12));
 			}

 			if ((minDist == null) || (minDist > dist)) {
 				to = Math.sqrt(lnm12 - dist2) / Math.sqrt(rl2);
 				from = Math.sqrt(ln2 - dist2) / Math.sqrt(rl2);
 				minDist = dist;
 				i = n;
 			}
 		}
 		if (to > 1) {
 			to = 1;
 		}
 		if (from > 1) {
 			to = 0;
 			from = 1;
 		}
 		var dx = aXys[i - 1].x - aXys[i].x;
 		var dy = aXys[i - 1].y - aXys[i].y;

 		x = aXys[i - 1].x - (dx * to);
 		y = aXys[i - 1].y - (dy * to);
 	}
 	return {
 		'x': x,
 		'y': y,
 		'i': i,
 		'to': to,
 		'from': from
 	};
 };
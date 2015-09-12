// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
debugger;

var apiKey = 'AIzaSyA-10-w06yl2bTDNkIPGT0sD52X32pAyZE';
var colours = ["red","orange","green","blue","purple"];
var snappedCoordinates  = [];
var zones = [];
var segments = [];
var map;

function initMap(){
	map = new google.maps.Map(document.getElementById('map'), {
		zoom: 12,
		center: {lat: -37.7962972, lng: 144.961397}
	});
	google.maps.event.addListenerOnce(map,"projection_changed", function() {
		phaseCoordinates();
		zoomToCoordinates();
		drawSegments();
		drawZones();	
		snapZonesToSegments();
	});
}

function phaseCoordinates(){	
	var temp = [];
	if (coordinates.length == 0){
		return;
	}
	var segment = [];
	segment.id = coordinates[0].seg;
	for (var i = 0; i < coordinates.length ; i++){
		var latlng = new google.maps.LatLng(
			coordinates[i].lat,coordinates[i].lng);
		if (segment.id != coordinates[i].seg){		
			segment.push(latlng);		
			temp.push(segment);
			segment = [];
			segment.id = coordinates[i].seg;
		}
		segment.push(latlng);
	}
	temp.push(segment);
	coordinates = temp;	
}

function zoomToCoordinates(){	
	var bounds = new google.maps.LatLngBounds();
	for (var i = 0; i < coordinates.length ; i++){
		for (var j = 0; j < coordinates[i].length; j++)
			bounds.extend(coordinates[i][j]);
	}
	map.fitBounds(bounds);
}

function drawSegments() {
	for (var i = 0; i < coordinates.length; i++){
		segment = new google.maps.Polyline({
			path: coordinates[i],
			strokeColor: colours[i%colours.length],
			strokeWeight: 5
		});
		segment.setMap(map);
		segment.segId = coordinates[i].id;
		segment.id = i;
		google.maps.event.addListener(segment, 'click', function(event) { 
			var form = $(".seg-form-" + this.segId).clone().show()[0];
			var infowindow = new google.maps.InfoWindow();
			infowindow.setContent(form);
			infowindow.setPosition(event.latLng);
			infowindow.open(map);
		});
		segments.push(segment);
	}
}

function drawZones(){
	// The start position
	var zone = new google.maps.Marker({
		position: coordinates[0][0]
	});
	zone.setMap(map);		
	zone.segAfter = segments[0];
	zones.push(zone);
	// Transfer zones
	for (var i = 1; i < coordinates.length; i++){
		var zone = new google.maps.Marker({
			position: coordinates[i][0],
			draggable: true
		});
		zone.setMap(map);		
		zone.segAfter = segments[i];
		zone.segBefore = segments[i - 1];		
		zones.push(zone);
	}
	// The end position
	var i = coordinates.length - 1;
	var j = coordinates[i].length -1;
	var zone = new google.maps.Marker({
		position: coordinates[i][j],
	});
	zone.setMap(map);		
	zone.segBefore = segments[i];
	zones.push(zone);	
}


function snapZonesToSegments(){
	for (var i = 1; i < zones.length - 1; i++){
		zone = zones[i];
		var before = zone.segBefore.getPath().getArray();
		var after = zone.segAfter.getPath().getArray();
		mergedLine = new google.maps.Polyline({
			path: before.concat(after)
		});
		zone.str = new SnapToRoute(map, zone, mergedLine);
		google.maps.event.addListener(zones[i], "dragend", function(){
			updateSegments(this);
		});
	}
}


function updateSegments(zone){
	var n = zone.str.getNthPoint();
	var segment;
	var before = false;
	if (n > zone.segBefore.getPath().length){
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
		removed = coordinates[id].splice(n-1, coordinates[id].length - n, latlng);
		coordinates[id+1] = removed.concat(coordinates[id+1]);
		coordinates[id+1].unshift(latlng);
	}
	else{
		removed = coordinates[id].splice(0, n, latlng);
		coordinates[id-1] = coordinates[id-1].concat(removed);
		coordinates[id-1].push(latlng);
	}
	for (var i = 0; i < coordinates.length; i++){
		segments[i].setPath(coordinates[i]);
	}
}

/** Snap to route library
*/
function SnapToRoute(map, marker, polyline) {
	this.routePixels_ = [];
	this.normalProj_ = map.getProjection();
	this.map_ = map;
	this.marker_ = marker;
	this.polyline_ = polyline;

	this.init_();
}

SnapToRoute.prototype.init_ = function () {
	this.loadLineData_();
	this.loadMapListener_();
};

SnapToRoute.prototype.updateTargets = function (marker, polyline) {
	this.marker_ = marker || this.marker_;
	this.polyline_ = polyline || this.polyline_;
	this.loadLineData_();
};

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

SnapToRoute.prototype.loadLineData_ = function () {
	var zoom = this.map_.getZoom();
	this.routePixels_ = [];
	var path = this.polyline_.getPath();
	for (var i = 0; i < path.getLength(); i++) {
		var Px = this.normalProj_.fromLatLngToPoint(path.getAt(i));
		this.routePixels_.push(Px);
	}
};

SnapToRoute.prototype.updateMarkerLocation_ = function (mouseLatLng) {
	var markerLatLng = this.getClosestLatLng(mouseLatLng);
	this.marker_.setPosition(markerLatLng);
};

SnapToRoute.prototype.getClosestLatLng = function (latlng) {
	var r = this.distanceToLines_(latlng);
	return this.normalProj_.fromPointToLatLng(new google.maps.Point(r.x, r.y));
};

SnapToRoute.prototype.getNthPoint = function () {
	latlng = this.marker_.getPosition();
	var r = this.distanceToLines_(latlng);
	return r.i;
}

SnapToRoute.prototype.distanceToLines_ = function (mouseLatLng) {
	var zoom = this.map_.getZoom();
	var mousePx = this.normalProj_.fromLatLngToPoint(mouseLatLng);
	var routePixels_ = this.routePixels_;
	return this.getClosestPointOnLines_(mousePx, routePixels_);
};

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
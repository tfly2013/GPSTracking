// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
debugger;

var apiKey = 'AIzaSyA-10-w06yl2bTDNkIPGT0sD52X32pAyZE';
var snappedCoordinates  = [];
var markers = [];
var map;
var trip;

function initMap(){
	map = new google.maps.Map(document.getElementById('map'), {
		zoom: 12,
		center: {lat: -37.7962972, lng: 144.961397}
	});
	zoomToCoordinates();
	addMarkers();
	snapToRoad();
}

function zoomToCoordinates(){
	var bounds = new google.maps.LatLngBounds();
	for (var i = 0; i < coordinates.length ; i++){
		var latlng = new google.maps.LatLng(
			coordinates[i].lat,coordinates[i].lng);
		bounds.extend(latlng);
	}
	map.fitBounds(bounds);
}

function addMarkers(){
	for (var i = 0; i < coordinates.length; i++){
		var marker = new google.maps.Marker({
			position: coordinates[i],
			draggable: true
		});
		marker.setMap(map);
		marker['id'] = i;
		google.maps.event.addListener(marker, 'dragend', function() { 
			trip.setMap(null);
			position = this.getPosition();
			coordinates[this['id']] = {lat: position.lat(), lng: position.lng()};
			snapToRoad();
		});
		markers.push(marker);
	}
	var markerCluster = new MarkerClusterer(map, markers, {gridSize: 15, maxZoom: 17, minimumClusterSize: 5});
}

function snapToRoad() {
	var pathValues = [];
	for (var i = 0; i < coordinates.length; i++){
		pathValues.push(coordinates[i].lat + "," + coordinates[i].lng);
	}
	$.get('https://roads.googleapis.com/v1/snapToRoads', {
		interpolate : true,
		key : apiKey,
		path : pathValues.join('|')
	}, function(data) {
		processSnapToRoadResponse(data);
		drawSnappedPolyline();
	});
}

function processSnapToRoadResponse(data) {
	snappedCoordinates = [];
	for (var i = 0; i < data.snappedPoints.length; i++) {
		var latlng = new google.maps.LatLng(
			data.snappedPoints[i].location.latitude,
			data.snappedPoints[i].location.longitude);
		snappedCoordinates.push(latlng);
	}
}

function drawSnappedPolyline() {
	trip = new google.maps.Polyline({
		path: snappedCoordinates,
		strokeColor: 'black',
		strokeWeight: 3
	});
	trip.setMap(map);
}
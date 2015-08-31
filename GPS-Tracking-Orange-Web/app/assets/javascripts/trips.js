// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
var apiKey = 'AIzaSyA-10-w06yl2bTDNkIPGT0sD52X32pAyZE';
var coordinates = [];

function snapToRoad() {
	$.get('https://roads.googleapis.com/v1/snapToRoads', {
		interpolate : true,
		key : apiKey,
		path : path.join('|')
	}, function(data) {
		processSnapToRoadResponse(data);
		drawSnappedPolyline();
	});
}

function processSnapToRoadResponse(data) {
	for (var i = 0; i < data.snappedPoints.length; i++) {
		var latlng = {
			lat : data.snappedPoints[i].location.latitude,
			lng : data.snappedPoints[i].location.longitude
		};
		coordinates.push(latlng);
	}
}

// Draws the snapped polyline (after processing snap-to-road response).
function drawSnappedPolyline() {
	var handler = Gmaps.build('Google');
	handler.buildMap({
		internal : {
			id : 'map'
		}
	}, function() {
		handler.addMarkers(raw);
		handler.addPolyline(coordinates, {
			strokeColor : '#FF0000'
		});
		handler.bounds.extend(coordinates[0]);
		handler.bounds.extend(coordinates[coordinates.length - 1]);
		handler.fitMapToBounds();
	});
}
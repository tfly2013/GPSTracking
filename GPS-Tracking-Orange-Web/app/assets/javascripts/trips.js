// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
debugger;

var apiKey = 'AIzaSyA-10-w06yl2bTDNkIPGT0sD52X32pAyZE';
var colours = ["red","orange","green","blue","purple"];
var snappedCoordinates  = [];
var zones = [];
var trip = [];
var map;

function initMap(){
	map = new google.maps.Map(document.getElementById('map'), {
		zoom: 12,
		center: {lat: -37.7962972, lng: 144.961397}
	});
	phaseCoordinates();
	zoomToCoordinates();
	addPolyline();
	addMarkers();		
}

function phaseCoordinates(){	
	var temp = [];
	if (coordinates.length == 0){
		return;
	}
	var segId = coordinates[0].seg;
	var segment = [];
	for (var i = 0; i < coordinates.length ; i++){
		var latlng = new google.maps.LatLng(
			coordinates[i].lat,coordinates[i].lng);
		latlng['seg'] = coordinates[i].seg;
		if (segId != coordinates[i].seg){		
			segment.push(latlng);		
			segId = coordinates[i].seg;
			temp.push(segment);
			segment = [];
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

function addMarkers(){
	for (var i = 0; i < coordinates.length; i++){
		var marker = new google.maps.Marker({
			position: coordinates[i][0]
		});
		marker.setMap(map);		
		marker['id'] = i;
		zones.push(marker);
	}
	// The last marker
	var i = coordinates.length - 1;
	var j = coordinates[i].length -1;
	var marker = new google.maps.Marker({
		position: coordinates[i][j]
	});
	marker.setMap(map);		
	marker['id'] = i + 1;
	zones.push(marker);
}


function addPolyline() {
	for (var i = 0; i < coordinates.length; i++){
		segment = new google.maps.Polyline({
			path: coordinates[i],
			strokeColor: colours[i%colours.length],
			strokeWeight: 5
		});
		segment.setMap(map);
		segment['seg'] = coordinates[i][0]['seg'];

		google.maps.event.addListener(segment, 'click', function(event) { 
			var form = $(".seg-form-" + this['seg']).clone().show()[0];
			var infowindow = new google.maps.InfoWindow();
			infowindow.setContent(form);
			infowindow.setPosition(event.latLng);
			infowindow.open(map);
		});
		trip.push(segment);
	}
}
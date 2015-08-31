// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
function init_map(){
	handler = Gmaps.build('Google');
	handler.buildMap({
		internal : {
			id : 'map'
		}
	}, function() {
		if (navigator.geolocation)
			navigator.geolocation.getCurrentPosition(displayOnMap);
	});
}

function displayOnMap(position) {
	var marker = handler.addMarker({
		lat : position.coords.latitude,
		lng : position.coords.longitude
	});
	handler.map.centerOn(marker);
};

$(init_map);
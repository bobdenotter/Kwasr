/* Prepare the map, set the styling, position the markers, render the marker, set the clickthrough */

google.maps.event.addDomListener(window, 'load', init);

var locations = [
      ['Reading', [30.467222, -36.011944], 'static/images/reading.png', '/reading.html'],
      ['Roskilde', [55.65, 45.083333], 'static/images/roskidle.png', '/roskidle.html'],
      ['Fujirock', [10.799, 103.783592], 'static/images/fujirock.png', '/fujirock.html']
    ];
function init() {
    var mapOptions = {
        zoom: 2	,
		draggable: true, 
		zoomControl: false, 
		scrollwheel: false, 
		disableDoubleClickZoom: true,
		disableDefaultUI: true,
        center: new google.maps.LatLng(35.610288,25.570312),
        styles: [{featureType:'water',elementType:'all',stylers:[{color:'#14c7af'},{visibility:'on'}]},
				{featureType:'road',stylers:[{'visibility':'off'}]},
				{featureType:'transit',stylers:[{'visibility':'off'}]},
				{featureType:'administrative',stylers:[{'visibility':'off'}]}, 
				{featureType:'administrative.country',stylers:[{'visibility':'on'}, {'color':'#14c7af'}, {'weight':'.75'}]},
				{featureType:'landscape',elementType:'all',stylers:[{'color':'#ffffff'}]},
				{featureType:'poi',stylers:[{'visibility':'off'}]},
				{elementType:'labels',stylers:[{'visibility':'off'},]}]
    };
    var mapElement = document.getElementById('mapbox');
    var map = new google.maps.Map(mapElement, mapOptions);

	var cur,
		marker,
		gMarkers = [];

	for (var i = 0, li = locations.length; i < li; ++i) {

		cur = locations[i];
		marker = new google.maps.Marker({
			map: map,
	      	position: new google.maps.LatLng(cur[1][0], cur[1][1]), /* locations[2] */
	 	  	icon: cur[2], /* locations[3] */
			url: cur[3]
	  	});
	
		google.maps.event.addListener(marker, "click", function() {
	    	window.location.assign(this.url);
	 	});
	
		gMarkers.push(marker);
	
	}
}


jQuery(function( $ ){

	$('nav#main a').bind('click', function(e){
		// e.preventDefault();
		console.log('klik 1', $(this).attr('href'));
		$('body').scrollTo($( $(this).attr('href') ), 300);
	});

	$('#devoptions').bind('change', function(e){
		// e.preventDefault();
		console.log('klik 2', $(this).attr('value'));
		$('body').scrollTo($("#" + $(this).attr('value') ), 300);
	});


	// Helper to make things like '<button data-action="eventView.load">' work
	$('button, h2 a').live('click', function(e){

		var action = $(this).data('action');

		// console.log('action', action);

		if (action != "") {
			eval(action);
		}

	});




/*



	// Links in headers in #list-events
	$('#list-events h2 a').live('click', function(){
		id = $(this).data('id');
		App.performanceC.loadPerformances(id);
		App.locationsC.loadLocations(id);
	});

	// Links in headers in #list-performances
	$('#list-performances h2 a').live('click', function(){
		id = $(this).data('id');
		console.log('id: ', id)
		// App.performanceC.loadPerformance(id);
	});
*/


});


function eventclick(id) {


	console.log('id', id);

	featureView.load(id);

}

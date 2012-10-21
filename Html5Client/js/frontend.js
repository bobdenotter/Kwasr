

jQuery(function( $ ){

	$('nav#main a').bind('click', function(e){
		// e.preventDefault();
		// console.log('klik', $(this).attr('href'));
		$('body').scrollTo($( $(this).attr('href') ), 300);
	});

	$('#devoptions').bind('change', function(e){
		// e.preventDefault();
		console.log('klik', $(this).attr('value'));
		$('body').scrollTo($("#" + $(this).attr('value') ), 300);
	});


	// Links in headers in #list-events
	$('#list-events h2 a').live('click', function(){
		id = $(this).data('id');
		console.log('id:', id);
		
		App.performanceC.loadPerformances(id);
		App.locationsC.loadLocations(id);

	});


});
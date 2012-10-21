// Voor een handige tutorial, zie: 
// http://return-true.com/2012/05/getting-started-with-emberjs/

/**************************
* Application
**************************/

App = Ember.Application.create();


/**************************
* Models
**************************/

App.Event = Ember.Object.extend({
	eve_countrycode: null,
	eve_end_date: null,
	eve_id: null,
	eve_name_en: null,
	eve_photo_url: null,
	eve_start_date: null,
	eve_url: null,
	evet_description: null,
	evet_languagecode: null,
	evet_map_url: null,
	evet_name: null,
	evet_name_slug: null,
	evet_official_website: null,
	logo: function() {
	    return 'http://kwasr.net/images/event/small-logo/' + this.get('eve_id') + '.png';
	}.property()	
});

App.Location = Ember.Object.extend({
	loc_id: null,
	loc_radius_meters: null,
	loct_description: null,
	loc_name_en: null,
	loc_latitude: null,
	loc_longitude: null,
	eve_id: null,
	loct_languagecode: null,
	loct_name_slug: null,
	loct_name: null,
	loc_photo_url: null
});

App.Feature = Ember.Object.extend({
	loc_id: null,
	feat_name_slug: null,
	feat_name: null,
	fea_id: null,
	fea_photo_url: null,
	sho_nr_posts: null,
	fea_imdb_id: null,
	fea_nr_posts: null,
	sho_id: null,
	fea_name_en: null,
	sho_start_datetime: null,
	sho_avg_post_rating: null,
	sho_end_datetime: null,
	fea_lastfm_id: null,
	feat_description: null,
	feat_languagecode: null,
	fea_avg_post_rating: null,
	image: function() {
	    // return 'http://kwasr.net/images/event/small-logo/' + this.get('eve_id') + '.png';
	    return this.get('fea_photo_url');
	}.property()	
});


/**************************
* Views
**************************/

App.eventV = Ember.View.extend(Ember.Metamorph, {

});


/**************************
* Controllers
**************************/

App.eventsC = Ember.ArrayController.create({
    content: [],
    loadEvents: function() {
    	var url = "http://api.kwasr.net/v1/nl/events";
		$.ajax({
			url: url,
			dataType: 'JSONP',
			context: this,
			success: this.loadEventsSucceeded,
			completed: this.loadEventsCompleted
		});
    },
    loadEventsSucceeded: function(data) {
		this.set('content', []);
		var events = data.events;
		events.forEach(function(event){
			var e = App.Event.create(event);
			this.pushObject(e);
		}, this);
    },
    loadEventsCompleted: function() {
    	if(xhr.status == 400 || xhr.status == 420) {
    		alert("API limit reached.");
     	}

    }
});


App.performanceC = Ember.ArrayController.create({
    content: [],
    loadPerformances: function(id) {

    	if (typeof(id)=="undefined") { id = 0;	}

    	var url = "http://api.kwasr.net/v1/nl/event/" + id;
		
		$.ajax({
			url: url,
			dataType: 'JSONP',
			context: this,
			success: this.loadPerformancesSucceeded,
			completed: this.loadPerformancesCompleted
		});
    },
    loadPerformancesSucceeded: function(data) {
		this.set('content', []);
		var features = data.features;
		features.forEach(function(feature){
			var e = App.Feature.create(feature);
			this.pushObject(e);
		}, this);
    },
    loadPerformancesCompleted: function() {
    	if(xhr.status == 400 || xhr.status == 420) {
    		alert("API limit reached.");
     	}

    }
});



App.locationsC = Ember.ArrayController.create({
    content: [],
    loadLocations: function(id) {

    	if (typeof(id)=="undefined") { id = 0;	}

    	var url = "http://api.kwasr.net/v1/nl/event/" + id;
		$.ajax({
			url: url,
			dataType: 'JSONP',
			context: this,
			success: this.loadLocationsSucceeded,
			completed: this.loadLocationsCompleted
		});
    },
    loadLocationsSucceeded: function(data) {
		this.set('content', []);
		var locations = data.locations;
		locations.forEach(function(locations){
			var e = App.Location.create(locations);
			this.pushObject(e);
		}, this);
    },
    loadLocationsCompleted: function() {
    	if(xhr.status == 400 || xhr.status == 420) {
    		alert("API limit reached.");
     	}

    }
});


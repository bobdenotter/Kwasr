
/**
 * Model for a single Kwasr event. Not to be confused with 'events' in Javascript.
 */
var Event = Backbone.Model.extend({

    initialize: function(){
        _.bindAll(this, 'logo');
    },

    defaults: {
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
        evet_official_website: null
    },
    logo: function() {
        return 'http://kwasr.net/images/event/small-logo/' + this.get('eve_id') + '.png';
    },

});     


/**
 * Collection for multiple Kwasr events. Not to be confused with 'events' in Javascript.
 */
var Eventlist = Backbone.Collection.extend({
    model: Event
});




var Location = Backbone.Model.extend({
    defaults: {
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
    }
});

var Locationlist = Backbone.Collection.extend({
    model: Location
});


var Feature = Backbone.Model.extend({
    defaults: {
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
        fea_avg_post_rating: null
    }, 
    image: function() {
        // return 'http://kwasr.net/images/event/small-logo/' + this.get('eve_id') + '.png';
        return this.get('fea_photo_url');
    }    
});

var Featurelist = Backbone.Collection.extend({
    model: Feature
});


/**
 * "View" controller for Events
 */
var EventView = Backbone.View.extend({

    initialize: function() {
        this.collection = new Eventlist();

        // Als 'add' van de collectie wordt aangeroepen, doen wij renderList..
        //this.collection.bind('add', this.renderList);

    },

    load: function() {
        var url = "http://api.kwasr.net/v1/nl/events";
        $.ajax({
            url: url,
            dataType: 'JSONP',
            context: this,
            success: this.loadSucceeded,
            completed: this.loadCompleted
        });
    },

    loadSucceeded: function(data) {

        data.events.forEach(function(eventdata){

            var event = new Event();
            event.set(eventdata);

            this.collection.add(event);

        }, this);

        this.render();

    },

    loadCompleted: function() {
        if(xhr.status == 400 || xhr.status == 420) {
            alert("API limit reached.");
        }
    },

    render: function() {
        var template = Handlebars.compile($("#eventlisttemplate").html());
        var html = template({ events: this.collection.toJSON() });
        console.log($(this.el));
        $('#eventlistview').html(html);
        return this;
    }


});


var eventView = new EventView();



var FeatureView = Backbone.View.extend({

    initialize: function() {
        this.collection = new Featurelist();

        // Als 'add' van de collectie wordt aangeroepen, doen wij renderList..
        //this.collection.bind('add', this.renderList);

    },

    load: function(id) {
        var url = "http://api.kwasr.net/v1/nl/event/" + id;
        $.ajax({
            url: url,
            dataType: 'JSONP',
            context: this,
            success: this.loadSucceeded,
            completed: this.loadCompleted
        });
    },

    loadSucceeded: function(data) {

        console.log(data);

        data.events.forEach(function(eventdata){

            var event = new Event();
            event.set(eventdata);

            this.collection.add(event);

        }, this);

        this.render();

    },

    loadCompleted: function() {
        if(xhr.status == 400 || xhr.status == 420) {
            alert("API limit reached.");
        }
    },

    render: function() {
        var template = Handlebars.compile($("#eventlisttemplate").html());
        var html = template({ events: this.collection.toJSON() });
        console.log($(this.el));
        $('#eventlistview').html(html);
        return this;
    }


});


var featureView = new FeatureView();



Handlebars.registerHelper('logo', function(object) {
  return 'http://kwasr.net/images/event/small-logo/' + object.eve_id + '.png';
});

/*


*/

/**************************
* Views
**************************/

/*
App.eventV = Ember.View.extend(Ember.Metamorph, {

});
*/


/**************************
* Controllers
**************************/


/*

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

    },
    loadPerformance: function(id) {


    },    
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

*/

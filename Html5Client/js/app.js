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
	    return '//kwasr.net/images/event/small-logo/' + this.get('eve_id') + '.png';
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
    	var me = this;
    	var url = "http://api.kwasr.net/v1/nl/events";
		$.ajax({
			url: url,
			dataType: 'JSONP',
			success: function(data) {
				me.set('content', []);
				$(data.events).each(function(index,event){
					var e = App.Event.create(event);
					me.pushObject(e);
					// console.log(event)
				});
			}
		});
    }
});


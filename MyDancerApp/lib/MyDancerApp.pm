package MyDancerApp;

use Dancer ':syntax';
use Dancer::Plugin::Database;
#use Dancer::Plugin::DBIC 'schema';
use Data::Dumper;
use I18N::AcceptLanguage;
use YAML;

#todo jas: dev and production environment (different port or different subdomain?)
#todo jas: move to DBIx::Class (do I want this or do I just want abstract base classes for tables?) or 
#          build modules for each table and offer calls to get data, so there don't have to be queries in this file
#todo jas: support urls without language code (for external links to the kwasr.net)
#todo jas: should I build a table FeatureAtEvent and store the average scores there?



our $VERSION = '0.1';

#todo jas: put this in another Module
sub my_uri_for {
	my ($uri) = @_;
	$uri = uri_for($uri);
#todo jas: change this static string in request->base->path()
	$uri =~ s/\/MyDancerApp\/public\/dispatch\.fcgi//;
	return $uri;
}

sub add_tags_to_structure {
	my ($lang, $data) = @_;

	if ( ref( $data ) eq 'HASH' ) {
		if ($data->{evet_name_slug}) {
			$data->{eve_url} = my_uri_for("/$lang/event/$data->{evet_name_slug}/");
		}
		if ($data->{use_name}) {
			$data->{use_url} = my_uri_for("/$lang/user/$data->{use_name}/");
		}
		if ($data->{evet_name_slug} and $data->{feat_name_slug}) {
			$data->{fea_url} = my_uri_for("/$lang/feature/$data->{evet_name_slug}/$data->{feat_name_slug}/");
		}
		if ($data->{sho_id} and $data->{use_name}) {
			$data->{pos_url} = my_uri_for("/$lang/post/$data->{use_name}/$data->{sho_id}/");
		}
		#taking the keys before the foreach because the hash changes during the loop
		my @keys = keys %$data;
		foreach ( @keys ) {
			if( /^(.*)_datetime$/ ) {
				#todo jas: add readable forms (with DateTime::Locale or Date::Calc or meybe even better to use Template::Plugin::Date?)
				$data->{"$1_date"} = substr( $data->{$_}, 0, 10 );
				$data->{"$1_time"} = substr( $data->{$_}, 11 );
			}
			if( /password/ ) {
				delete $data->{$_};
			} else {
		    	add_tags_to_structure($lang, $data->{$_});
			}
		}
	} elsif	( ref( $data ) eq 'ARRAY' ) {
		foreach ( @$data ) {
		    add_tags_to_structure($lang, $_);
		}
	}
	
}

hook 'before_template_render' => sub {
    my $tokens = shift;

	$tokens->{request_base_path} = request->base->path;
	$tokens->{request_path} = request->path;
	$tokens->{request_uri} = request->request_uri;

	#todo jas: show 404 if it doesn't match a supported language?
	my $lang = request->request_uri =~ /^\/(..)(\/.*)/ ? $1 : "en";

	# add current language
	$tokens->{lang} = $lang;
	my $language_file = setting('appdir')."/languages/$lang.yml";
	$tokens->{text} = YAML::LoadFile( $language_file );
	#todo jas: the uri should bring the user to the current page in the selected language. But that is quite complicated
	#          as the path needs to be translated as well
	$tokens->{langs} = [map({code => $_, is_current_lang => $lang eq $_, uri => "/$_/"}, @{ setting("supported_languages") } ) ];
	
	add_tags_to_structure( $tokens->{lang}, $tokens );
	$Data::Dumper::Sortkeys = 1;
	$tokens->{dump} = "<pre>" . Dumper($tokens) . "</pre>";
};

get '/' => sub {
	my $lang = I18N::AcceptLanguage->new()->accepts( 
		request->env()->{HTTP_ACCEPT_LANGUAGE}, setting("supported_languages") ) || 'en';
    return redirect my_uri_for("/$lang/");
};

get '/test/' => sub {
    template 'test';
};

get '/:lang/' => sub {

	# get event list
	my $sth = database->prepare( 'SELECT * FROM Event e, EventTrans et WHERE e.eve_id=et.eve_id AND evet_languagecode=? ORDER BY eve_start_date' );
	$sth->execute(param('lang'));
	my @r = (); while( my $row = $sth->fetchrow_hashref() ) { push @r, { %$row } };
	template 'index' => { 
	    events => \@r,
	};
};

get '/:lang/event/:event/' => sub {
	
	# get event details
	my $event = database->selectrow_hashref('SELECT * FROM Event e, EventTrans et WHERE e.eve_id=et.eve_id AND evet_languagecode=? AND evet_name_slug=?', undef, param('lang'),param('event'));
	
	#get location details
	my $sth = database->prepare( 'SELECT * FROM Location l, LocationTrans lt WHERE l.loc_id=lt.loc_id AND loct_languagecode=? AND l.eve_id=? ORDER BY lt.loct_name ASC' );
	$sth->execute(param('lang'),$event->{eve_id});
	my @locs = (); while( my $row = $sth->fetchrow_hashref() ) { push @locs, { %$row } };
	my $loc_ids = join( ",", map( $_->{loc_id}, @locs ) );
	
	#get Feature details
	$sth = database->prepare( "SELECT * FROM Feature p, FeatureTrans pt, Showing s WHERE p.fea_id=pt.fea_id AND pt.feat_languagecode=? AND s.fea_id=p.fea_id AND s.loc_id IN ($loc_ids) ORDER BY pt.feat_name ASC, s.sho_start_datetime ASC" );
	$sth->execute(param('lang'));
	my @features = (); while( my $row = $sth->fetchrow_hashref() ) { push @features, { %$row, evet_name_slug => $event->{evet_name_slug} } };

	template 'event' => { 
	    event => $event,
		locations => \@locs,
		features => \@features,
	};
};

get '/:lang/feature/:event/:feature/' => sub {
	# Different ways to talk about a feature
	#	1) feature (so about a film or band)
	#	2) feature, event (so about a film or band on a festival)
	#	3) feature, event, location (This does not make sense)
	#	4) showing (so about a single time a band played a a movie was shown)
	# This is the implementation of 2

	#event id from event slug
	my $event = database->selectrow_hashref( 'SELECT * FROM Event e, EventTrans et WHERE e.eve_id=et.eve_id AND et.evet_name_slug = ? AND et.evet_languagecode = ?', 
		undef, param('event'), param('lang') );
	send_error("Event Not Found", 404) unless $event;

	#get feature details from snug
	my $feature = database->selectrow_hashref( 'SELECT * FROM Feature f, FeatureTrans ft WHERE f.fea_id=ft.fea_id AND ft.feat_name_slug = ? AND ft.feat_languagecode = ?', 
		undef, param('feature'), param('lang') );
	send_error("Feature Not Found", 404) unless $feature;
	
	# all showings for this event from event id
	my $sth = database->prepare( 'SELECT * FROM Location l, LocationTrans lt, Showing s WHERE l.loc_id=s.loc_id AND l.loc_id = lt.loc_id AND lt.loct_languagecode=? AND l.eve_id=? AND s.fea_id = ?' );
	$sth->execute( param('lang'), $event->{eve_id}, $feature->{fea_id} );
	my @showings = (); while( my $row = $sth->fetchrow_hashref() ) { push @showings, { %$row } };
	send_error("No showings Found", 404) unless @showings;

    template 'feature' => { 
		event => $event,
		feature => $feature,
	    showings => \@showings,
	};
};

get '/:lang/user/:user/' => sub {
	
	# get user details
	my $user = database->selectrow_hashref( 'SELECT * FROM User u WHERE use_name=?', undef, param('user') );
	send_error("User Not Found", 404) unless $user;
	
	#get posts
	#todo jas: add a smart pagination, order and/or limit
	my $sth = database->prepare( "SELECT * FROM Post, Showing s, Location l, LocationTrans lt, Event e, EventTrans et, Feature p, FeatureTrans pt WHERE use_id = ? AND Post.sho_id = s.sho_id AND s.loc_id = l.loc_id AND l.loc_id = lt.loc_id AND lt.loct_languagecode=? AND s.fea_id=p.fea_id AND l.eve_id=e.eve_id AND e.eve_id = et.eve_id AND et.evet_languagecode=? AND p.fea_id=pt.fea_id AND pt.feat_languagecode=?" );
	$sth->execute( $user->{use_id}, param('lang'), param('lang'), param('lang') );
	my @posts = (); while( my $row = $sth->fetchrow_hashref() ) { push @posts, { %$row, use_name => $user->{use_name} } };
	
    template 'user' => { 
	    user => $user,
		posts => \@posts,
	};
};

get '/:lang/post/:user/:sho_id/' => sub {

	# get user details
	my $user = database->selectrow_hashref( 'SELECT * FROM User u WHERE use_name=?', undef, param('user') );
	send_error("User Not Found", 404) unless $user;

	# get post details
	my $post = database->selectrow_hashref('SELECT * FROM Post, Showing s, Location l, LocationTrans lt, Event e, EventTrans et, Feature p, FeatureTrans pt WHERE Post.use_id=? AND Post.sho_id=? AND s.sho_id = Post.sho_id AND s.loc_id = l.loc_id AND l.loc_id = lt.loc_id AND lt.loct_languagecode=? AND s.fea_id=p.fea_id AND l.eve_id=e.eve_id AND e.eve_id = et.eve_id AND et.evet_languagecode=? AND p.fea_id=pt.fea_id AND pt.feat_languagecode=?', undef, $user->{use_id}, param('sho_id'),param('lang'),param('lang'),param('lang'));
	send_error("Post Not Found", 404) unless $post;
	
    template 'post' => { 
	    user => $user,
	    post => $post,
	};
};

true;

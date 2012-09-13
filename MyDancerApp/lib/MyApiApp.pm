package MyDancerApp;

use Dancer ':syntax';
use Dancer::Plugin::Database;
#use Dancer::Plugin::DBIC 'schema';
use Data::Dumper;
use Digest::SHA;
use I18N::AcceptLanguage;
use YAML;


set serializer => 'JSON';


our $VERSION = '0.1';

get '/' => sub {
	send_file '/index.html'
};

get '/:version/config' => sub {
    return {
		supported_languages => setting("supported_languages"),
	};
};

get '/:version/new_user_challenge' => sub {
	my $challenge = Digest::SHA::sha1_hex(localtime . rand . "some weirdo string");
	database->do("INSERT INTO Challenge VALUES (?, null)", undef, $challenge);
    return {
		challenge => $challenge,
	};
};

get '/:version/:lang/events' => sub {

	# get event list
	my $sth = database->prepare( 'SELECT * FROM Event e, EventTrans et WHERE e.eve_id=et.eve_id AND evet_languagecode=?' );
	$sth->execute(param('lang'));
	my @r = (); while( my $row = $sth->fetchrow_hashref() ) { push @r, { %$row } };
	return { 
	    events => \@r,

	};
};

get '/:version/:lang/event/:eve_id' => sub {
	my @locs = ();
	my @features = ();
	
	#get location details
	my $sth = database->prepare( 'SELECT * FROM Location l, LocationTrans lt WHERE l.loc_id=lt.loc_id AND loct_languagecode=? AND l.eve_id=?' );
	$sth->execute(param('lang'),param('eve_id'));
	while( my $row = $sth->fetchrow_hashref() ) { push @locs, { %$row } };
	
	#get Feature details, including all showing details
	if( @locs ) {
		my $loc_ids = join( ",", map( $_->{loc_id}, @locs ) );
		$sth = database->prepare( "SELECT * FROM Feature p, FeatureTrans pt, Showing s WHERE p.fea_id=pt.fea_id AND pt.feat_languagecode=? AND s.fea_id=p.fea_id AND s.loc_id IN ($loc_ids) ORDER BY pt.feat_name ASC, s.sho_start_datetime ASC" );
		$sth->execute(param('lang'));
		while( my $row = $sth->fetchrow_hashref() ) { push @features, { %$row } };
	}
	
	return { 
		locations => \@locs,
		features => \@features,
	};
};

get '/:version/:lang/user/:use_id' => sub {
#todo jas: If a user has 1000+ posts, we probably want to provide a way to limit the posts. Maybe provide a event id or
#     a data range
	
	# get user details
	my $user = database->selectrow_hashref( 'SELECT * FROM User WHERE use_id=?', undef, param('use_id') );
	send_error("Not Found", 404) unless $user;
	
	#get posts
	my $sth = database->prepare( "SELECT * FROM Post WHERE use_id = ?" );
	$sth->execute( $user->{use_id} );
	my @posts = (); while( my $row = $sth->fetchrow_hashref() ) { push @posts, $row };
	
    return { 
	    user => $user,
		posts => \@posts,
	};
};

get '/:version/test' => sub {
    return { name => "Jasper" }
};


true;

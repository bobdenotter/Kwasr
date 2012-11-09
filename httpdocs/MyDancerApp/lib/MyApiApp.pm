package MyDancerApp;

use Dancer ':syntax';
use Dancer::Plugin::Database;
#use Dancer::Plugin::DBIC 'schema';
use Data::Dumper;
use Digest::SHA;
use I18N::AcceptLanguage;
use YAML;


our $VERSION = '0.1';

use constant {
    # Formats
    JSON_FT  => "json",
    XML_FT   => "xml",
    YAML_FT  => "yaml",
    TEXT_FT  => "text",
    HTML_FT  => "html",
 
    # Content Types
    JSONP_CT => "text/javascript",
    JSON_CT  => "application/json",
    XML_CT   => 'text/xml',
    YAML_CT  => 'application/yaml',
    TEXT_CT  => "text/plain",
};

sub return_json {
    my ($data, $callback) = @_;
    my $ret = $callback ? "$callback(" : '';
    $ret .= to_json($data);
    $ret .= ");" if $callback;
    content_type($callback ? JSONP_CT : JSON_CT);
    return $ret;
}

get '/' => sub {
	send_file '/index.html'
};

get '/:version/config' => sub {
    return return_json( { supported_languages => setting("supported_languages") }, param("callback") || undef );
};

get '/:version/new_user_challenge' => sub {
	my $challenge = Digest::SHA::sha1_hex(localtime() . rand() . "some weirdo string");
	database->do("INSERT INTO Challenge VALUES (?, null)", undef, $challenge);
    return return_json( { challenge => $challenge }, param("callback") || undef );
};

get '/:version/:lang/events' => sub {

	# get event list
	my $sth = database->prepare( 'SELECT * FROM Event e, EventTrans et WHERE e.eve_id=et.eve_id AND evet_languagecode=?' );
	$sth->execute(param('lang'));
	my @r = (); while( my $row = $sth->fetchrow_hashref() ) { push @r, { %$row } };
	return return_json( { events => \@r }, param("callback") || undef );
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
	my %tf; # temp features
	foreach my $f (@features) {
		$tf{$f->{fea_id}}{count} += $f->{sho_nr_posts};
		$tf{$f->{fea_id}}{avg} += $f->{sho_nr_posts} * $f->{sho_avg_post_rating};
	} 
	foreach my $f (@features) {
		$f->{fea_nr_posts} = $tf{$f->{fea_id}}{count};
		$f->{fea_avg_post_rating} = $tf{$f->{fea_id}}{count} ? $tf{$f->{fea_id}}{avg} / $tf{$f->{fea_id}}{count} : 0;
	}
	
	return return_json( { locations => \@locs,
		features => \@features }, param("callback") || undef );
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
	
    return return_json( { user => $user,
		posts => \@posts }, param("callback") || undef );
};

get '/:version/test' => sub {
    return return_json( { name => "Jasper" }, param("callback") || undef );
};


true;

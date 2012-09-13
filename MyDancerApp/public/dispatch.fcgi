#!/usr/bin/env perl
use Dancer ':syntax';
use FindBin '$RealBin';
use Plack::Handler::FCGI;

# For some reason Apache SetEnv directives dont propagate
# correctly to the dispatchers, so forcing PSGI and env here 
# is safer.
set apphandler => 'PSGI';
set environment => 'development';

#todo jas: better to check for the subdomain, but I don't know where to find that.
# should be in HTTP_HOST and/or SERVER_NAME, but no idea how to access that, it is not in %ENV
my $app_script_name = ( $ENV{PP_CUSTOM_PHP_INI} =~ /api\.kwasr\.net/ ) ? 'api_app.pl' : 'www_app.pl';

# I use this for debugging this script as I cannot figure out where STDERR goes to... :-(
#open (MYFILE, '>>data.txt');use Data::Dumper;
#print MYFILE Dumper(1,$ENV{PP_CUSTOM_PHP_INI},$ENV{PP_CUSTOM_PHP_INI} =~ /api/,$RealBin,$app_script_name, \%ENV, $0);
#close (MYFILE);

my $psgi = path($RealBin, '..', 'bin', $app_script_name);
my $app = do($psgi);
die "Unable to read startup script: $@" if $@;
my $server = Plack::Handler::FCGI->new(nproc => 5, detach => 1);

$server->run($app);

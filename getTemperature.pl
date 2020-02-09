#!/usr/bin/perl
use strict;
use warnings;

use lib '/root/lib';
use zway::getSession;
use zway::getRoom;
use zway::getDevices;
use zway::getAlarm;
use zway::getTemperature;
use zway::setLogout;

use LWP::UserAgent;
use HTTP::Request;
use HTTP::Cookies;
use JSON::MaybeXS qw(encode_json decode_json);
use Math::Round qw/nearest/;
use MIME::Base64 qw(encode_base64 decode_base64);

use Data::Dumper;

my $api = "192.168.88.2";
my $username = "admin";
my $password = "cGFzc3dvcmQ=";

my $session = zway::getSession({ api => $api, username => $username, password => $password });
if (not $session->{code} =~ /200/) {
        print $session->{message} . "\n";
} else {
        $session = $session->{data}->{sid};
}
my @room = zway::getRoom({ api => $api, session => $session });
my @devices = zway::getDevices({ api => $api, session => $session, room => \@room });
my $alarm = zway::getAlarm({ devices => \@devices });
my $temperature = zway::getTemperature({ devices => \@devices });
my $logout = zway::setLogout({ api => $api, session => $session });

my $authheader = "Basic " . encode_base64($username . ":" . $password);
my $request = HTTP::Request->new(POST => "http://" . $api . ":8086/write?db=mydb");
$request->header("Authorization" => $authheader);
$request->content($temperature);
my $ua = new LWP::UserAgent();
my $post = $ua->request($request);

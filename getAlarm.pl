#!/usr/bin/env perl
use strict;
use warnings;
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Cookies;
use JSON::MaybeXS qw(encode_json decode_json);
use Math::Round qw/nearest/;

use Data::Dumper;

my $api = "192.168.88.215";
my $username = "admin";
my $password = "password";

my $session = getSession({ api => $api, username => $username, password => $password });
if (not $session->{code} =~ /200/) {
	print ($session->{message});
} else {
	$session = $session->{data}->{sid};
}

my @array = getDevices({ api => $api, session => $session });
my $array = getAlarm({ api => $api, array => \@array  });

print Dumper($array);

sub getAlarm {
	my $param = shift;
	my $api = $param->{'api'};
	my @array = @{$param->{'array'}};
	my @temperaturearray;
	for my $temperature (@array) {
		if ($temperature->{probeType} =~ /alarmSensor_smoke|alarm_smoke/) {
			if ($temperature->{level} =~ /on/) {
				my @cell = ($temperature->{title},$temperature->{level});
				push(@temperaturearray,\@cell);
			}
		}
	}
	my $postparams = join ",", map { join "=", @$_ } @temperaturearray;
	if ($postparams) {
		$postparams = "Brandmeldealarm" . " " . $postparams;
	}
	return $postparams;
}

sub getTemperature {
	my $param = shift;
	my $api = $param->{'api'};
	my @array = @{$param->{'array'}};
	my @temperaturearray;
	for my $temperature (@array) {
		if ($temperature->{probeType} =~ /temperature/) {
			my $level = nearest('0.1',$temperature->{level});
			my @cell = ($temperature->{title},$level);
			push(@temperaturearray,\@cell);
		}
	}
	my $postparams = join ",", map { join "=", @$_ } @temperaturearray;
	if ($postparams) {
		$postparams = "Temperature,Temperature=Fibaro" . " " . $postparams;
	}
	my $request = HTTP::Request->new(POST => "http://" . $api . ":8086/write?db=mydb");
	$request->content($postparams);
	my $ua = new LWP::UserAgent();
	my $post = $ua->request($request);
	return $post;
}

sub getDevices
{
	my $param = shift;
	my $api = $param->{'api'};
	my $session = $param->{'session'};
	my $ua = new LWP::UserAgent();
	my $cookie_jar = HTTP::Cookies->new();
	$cookie_jar->set_cookie(0,"ZWAYSession", $session,"/",$api);
	$ua->cookie_jar($cookie_jar);

	my $request = HTTP::Request->new(GET => "http://" . $api . ":8083/ZAutomation/api/v1/devices");
	$request->header("Accept" => 'application/json');
	$request->header("Content-Type" => 'application/json');
	my $response = $ua->request($request);
	my $data = decode_json $response->decoded_content();
	my @array;
	for my $devices ($data->{data}->{devices}->@*) {
		my $title = $devices->{metrics}->{title};
		$title =~ s/([#() ])//g;
		my $cell = {
			title => $title,
			id => $devices->{id},
			level => $devices->{metrics}->{level},
			probeType => $devices->{probeType}
		};
		push(@array,$cell);
	}
	return @array;
}

sub getSession
{
	my $param = shift;
	my $api = $param->{'api'};
	my $username = $param->{'username'};
	my $password = $param->{'password'};
	
	my $header = HTTP::Headers->new;
	$header->push_header("Accept" => 'application/json');
	$header->push_header("Content-Type" => "application/json");

	use JSON::MaybeXS qw(encode_json decode_json);
	my $data = {
		"default_ui" =>  "1",
		"keepme" =>  "false",
		"form" =>  "true",
		"password" =>  $password,
		"login" => $username,
	};
	 
	my $json = JSON::MaybeXS->new(utf8 => 1, pretty => 1, sort_by => 1);
	my $data_json = $json->encode($data);

	my $request = HTTP::Request->new(
	  "POST",
	  "http://" . $api . ":8083/ZAutomation/api/v1/login",
	  $header,
	  $data_json,
	);

	my $ua = new LWP::UserAgent();
	my $response = $ua->request($request);
	my $json_decode = decode_json $response->decoded_content();
	return ($json_decode);
}

package zway;

use strict;
use warnings;
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Cookies;
use JSON::MaybeXS qw(encode_json decode_json);
use Math::Round qw/nearest/;
use MIME::Base64 qw(encode_base64 decode_base64);

sub getDevices
{
        my $param = shift;
        my $api = $param->{'api'};
        my $session = $param->{'session'};
        #my @room = getRoom({ api => $api, session => $session });
	my @room = @{$param->{'room'}};
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
                my @location = map { $_->{id} =~ $devices->{location} ? ($_->{title}) : () } @room;
                my $title = $devices->{metrics}->{title};
                $title =~ s/([#() ])//g;
                my $cell = {
                        title => $title,
                        id => $devices->{id},
                        location => shift @location,
                        level => $devices->{metrics}->{level},
                        probeType => $devices->{probeType}
                };
                push(@array,$cell);
        }
        return @array;
}
1;

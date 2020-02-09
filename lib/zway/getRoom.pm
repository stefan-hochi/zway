package zway;

use strict;
use warnings;
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Cookies;
use JSON::MaybeXS qw(encode_json decode_json);
use Math::Round qw/nearest/;
use MIME::Base64 qw(encode_base64 decode_base64);

sub getRoom
{
        my $param = shift;
        my $api = $param->{'api'};
        my $session = $param->{'session'};
        my $ua = new LWP::UserAgent();
        my $cookie_jar = HTTP::Cookies->new();
        $cookie_jar->set_cookie(0,"ZWAYSession", $session,"/",$api);
        $ua->cookie_jar($cookie_jar);

        my $request = HTTP::Request->new(GET => "http://" . $api . ":8083/ZAutomation/api/v1/locations");
        $request->header("Accept" => 'application/json');
        $request->header("Content-Type" => 'application/json');
        my $response = $ua->request($request);
        my $data = decode_json $response->decoded_content();
        my @tmpArray;
        for my $rooms ($data->{data}->@*) {
                my $cell = {
                        title => $rooms->{title},
                        id => $rooms->{id}
                };
                push(@tmpArray,$cell);
        }

        return @tmpArray;
}
1;

package zway;

use strict;
use warnings;
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Cookies;
use JSON::MaybeXS qw(encode_json decode_json);
use Math::Round qw/nearest/;
use MIME::Base64 qw(encode_base64 decode_base64);

sub getSession
{
        my $param = shift;
        my $api = $param->{'api'};
        my $username = $param->{'username'};
        my $password = decode_base64($param->{'password'});

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
1;

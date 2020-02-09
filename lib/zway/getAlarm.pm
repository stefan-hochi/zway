package zway;

use strict;
use warnings;
use Math::Round qw/nearest/;

sub getAlarm {
        my $param = shift;
        my @devices = @{$param->{'devices'}};
        my @tmpArray;
        for my $temperature (@devices) {
                if ($temperature->{probeType} =~ /alarmSensor_smoke|alarm_smoke/) {
                        if ($temperature->{level} =~ /on/) {
                                my @cell = ($temperature->{location} . $temperature->{title},$temperature->{level});
                                push(@tmpArray, map { join "=", @$_ } \@cell);
                                #push(@tmpArray,\@cell);
                        }
                }
        }
        #my $postparams = join ",", map { join "=", @$_ } @tmpArray;
        my %hash   = map { $_ => 1 } @tmpArray;
        my $postparams = join ",", map { $_ } keys %hash;
        if ($postparams) {
                $postparams = "Brandmeldealarm" . " " . $postparams;
        }
        return $postparams;
}
1;

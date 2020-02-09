package zway;

use strict;
use warnings;
use Math::Round qw/nearest/;

sub getTemperature {
        my $param = shift;
	my @devices = @{$param->{'devices'}};
        my @tmpArray;
        for my $temperature (@devices) {
                if ($temperature->{probeType} =~ /temperature/) {
                        my $level = nearest('0.1',$temperature->{level});
                        my $title = $temperature->{location} . $temperature->{title};
                        my @cell = ($title,$level);
                        push(@tmpArray,\@cell);
                }
        }
        my $postparams = join ",", map { join "=", @$_ } @tmpArray;
        if ($postparams) {
                $postparams = "Temperature,Temperature=Fibaro" . " " . $postparams;
        }
	return $postparams;
}
1;

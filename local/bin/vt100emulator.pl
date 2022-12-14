#!/usr/bin/env perl
# Source: https://klipkyle.gitlab.io/blog/2017-10-22-vt100-ani.html | https://archive.is/3wXjF
#
# scat 
#
# sleepy-cat - like cat, except delay a little bit to emulate the
# behavior of an old terminal
#
# By default a delay is inserted after every line feed (to emulate
# screen refresh), and a smaller delay is inserted between every
# character (to emulate slow baud rate).
#
# -nXX sets the newline output rate in frames per second (default is 60)
# -cXX sets the character output rate in frames per second (default 12800)
#      (set either option to 0 to disable)
#
# There are no spaces between the letter option and its number value
# (i.e. "-c15" is valid, but "-c 15" is not)

use strict;
use warnings;
use Time::HiRes qw(time usleep);
use List::Util qw(max);

my $linewait = 1e6 / 60;
my $charwait = 1e6 / 12800;

# Parse parameters
while (defined($ARGV[0]) && $ARGV[0] =~ /^-/) {
    $_ = shift @ARGV;
    if (/^-n(\d+)/) {$linewait = $1 == 0? 0: 1e6 / $1;}
    elsif (/^-c(\d+)/) {$charwait = $1 == 0 ? 0 : 1e6 / $1;}
    elsif (/^-$/) {unshift @ARGV, $_; last}
    elsif (/^--$/) {last;}
    else {die "Unknown parameter $_";}
}

if ($charwait > 0) {
    $| = 1;
    while (<>) {
	my $t0 = time();
	foreach (split //, $_) {
	    print;
	    usleep($charwait);
	}
	my $elapsed = (time() - $t0) * 1e6;
	usleep(max(0, $linewait - $elapsed));
    }
}
# If charwait is disabled, we can skip many extra steps.
else {
    while (<>) {
	print;
	usleep($linewait);
    }
}

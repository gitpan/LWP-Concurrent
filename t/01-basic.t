#!perl
use strict;
use warnings;
use Data::Dumper;

#use Test::More tests => 1;
use Test::More qw(no_plan);
use LWP::Concurrent;

ok(1);

my $c = LWP::Concurrent->new();
my @urls = map { "http://joshr.com/index.html" } (1 .. 4); 
my $returns = $c->get_concurrent( urls => \@urls );

cmp_ok( scalar(@urls), '==', scalar( keys %$returns ) );




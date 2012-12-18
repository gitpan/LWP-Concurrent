#!perl 

use Test::More tests => 1;

BEGIN {
    use_ok( 'LWP::Concurrent' ) || print "Bail out!\n";
}

#diag( "Testing LWP::Concurrent $LWP::Concurrent::VERSION, Perl $], $^X" );

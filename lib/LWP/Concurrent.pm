use strict;
use warnings;
package LWP::Concurrent;

# ABSTRACT: Runs multiple LWP Client connections in parallel


use Moo;
use Time::HiRes qw(time sleep);
use HTTP::Request;
use Data::Dumper;

use HTTP::Async;
use URI;

has timeout   => ( is => "rw", default => sub { 3.00 } );
has idlesleep => ( is => "rw", default => sub { 0.03 } );   # same as HTTP::Async's poll_interval

# my $data = get_concurrent( { urls => [$u1, $u2], timeout=>0.99, idlesleep=>0.01 } );
# $data is a hashref where the keys are the urls and the responses are 
# HTTP::Response objects. 
# as they come back from  HTTP::Async. See text after the __END_ tag below for an example.
sub get_concurrent {
    my ($self, %hash) = @_;
    my ($urls ) = @hash{ qw( urls ) };
    my @requests = map { HTTP::Request->new( GET => $_ ) } @$urls;
    my $ret = $self->operate_concurrently( requests => \@requests );
    return $ret;
}

sub operate_concurrently {
    my ($self, %hash) = @_;
    my $requests = $hash{requests};

    my $async = HTTP::Async->new( timeout=>$self->timeout, poll_interval=>$self->idlesleep );
    my $start_t = time();
    my $now;
    my %to_return;
    my $counter = 0;
    for my $request (@$requests) {
        $async->add( $request );    # an HTTP::Request object
    }
    while ( ($now = time()) && $now - $start_t < $self->timeout && $async->not_empty ) {
        if ( my $response = $async->wait_for_next_response($self->idlesleep) ) {
            my $uri = $response->request()->url();
            $to_return{$counter} = {uri=>$uri, response=>$response};   # uri  => the response _object_ 
            $counter++;
        } 
        # else {            
            #sleep( $self->idlesleep ) if $self->idlesleep;  # sleep a while if the caller so desires 
        #}    
    }    
    return \%to_return; # return the data we found; keys are the response numbers, 
                        # values are a hash with urls and  HTTP::Response objects.
}


1;

=pod

=head1 NAME

LWP::Concurrent -- Provides easy interface to making parallel/concurrent LWP requests

=head1 SYNOPSIS

    my $lwpc = LWP::Concurrent->new()
    my $responses = $lwpc->get_concurrent( urls=>[ "http://example.com/url1", "http://example.com/url2" ] );

=head1 DESCRIPTION

Makes concurrent LWP requests

=head1 METHODS

=over 4

=item $lwpc = LWP::Concurrent->new( );  # or
=item $lwpc = LWP::Concurrent->new( idlesleep => 0.05, timeout => 0.4 );

returns a new LWP::Concurrent object.  

=item $lwpc->timeout()
=item $lwpc->idlesleep()

Gets or sets the timeout or idlesleep params.

=item $results = $lwpc->get_concurrent( urls=> \@urls )

performs a GET on the specified urls, returning a hashref where the keys are the response numbers, 
and the values are the urls and their responses

=item $results = $lwpc->operate_concurrently( requests => \@request_objects )

performs actions on HTTP servers as specified by the passed request objects,
returning a hashref where the keys are the response numbers, 
and the values are the urls and their responses

=back

=head1 TO DO

If you want such a section.

=head1 BUGS

None

=head1 COPYRIGHT

Copyright (c) 2012 Josh Rabinowitz, All Rights Reserved.

=head1 AUTHORS

Josh Rabinowitz

=cut    


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
    my ($self, $hashref) = @_;
    my %hash = %$hashref;
    my ($urls ) = @hash{ qw( urls ) };
    my @requests = map { HTTP::Request->new( GET => $_ ) } @$urls;
    my $ret = $self->operate_concurrently( { requests => \@requests } );
    return $ret;
}

sub operate_concurrently {
    my ($self, $hashref) = @_;
    my $requests = $hashref->{requests};

    my $async = HTTP::Async->new( timeout=>$self->timeout, poll_interval=>$self->idlesleep );
    my $start_t = time();
    my $now;
    my %to_return;
    my $counter = 0;
    for my $request (@$requests) {
        $async->add( $request );    # an HTTP::Request object
    }
    while ( ($now = time()) && $now - $start_t < $self->timeout && $async->not_empty ) {        
        if ( my $response = $async->next_response ) {            
            my $uri = $response->request()->url();            
            $to_return{$counter} = {uri=>$uri, response=>$response};   # uri  => the response _object_ 
            $counter++;
        } else {            
            sleep( $self->idlesleep ) if $self->idlesleep;  # sleep a while if the caller so desires        
        }    
    }    
    return \%to_return; # return the data we found; keys are the response numbers, 
                        # values are a hash with urls and  HTTP::Response objects.
}


1;

__END__

'http://media.dev.shuttercorp.net/library/shutterstock/photo/500000' => bless( {
   '_content' => '{"r_rated":"0","status":"approved","aspect":0.75,"categories":[{"name":"Food and Drink","id":"6"},{"name":"NOT-CATEGORIZED","id":"20"}],"vector_extension":null,"sizes":{"huge_jpg":{"width":1920,"height_in":"8.5\\"","width_cm":"16.3 cm","size_in_bytes":2153472,"width_in":"6.4\\"","name":"huge_jpg","height_cm":"21.7 cm","height":2560,"display_name":"Huge","human_readable_size":"2.1 MB","dpi":300,"format":"jpg"},"medium_jpg":{"width":750,"height_in":"4.4\\"","width_cm":"6.3 cm","size_in_bytes":530432,"width_in":"2.5\\"","name":"medium_jpg","height_cm":"11.3 cm","height":1333,"display_name":"Med","human_readable_size":"518 KB","dpi":300,"format":"jpg"},"huge_tiff":{"width":1920,"height_in":"8.5\\"","width_cm":"16.3 cm","size_in_bytes":14745600,"width_in":"6.4\\"","name":"huge_tiff","height_cm":"21.7 cm","height":2560,"display_name":"Huge","human_readable_size":"14.1 MB","dpi":300,"format":"tiff"},"supersize_jpg":{"width":3840,"height_in":"17.1\\"","width_cm":"32.5 cm","size_in_bytes":4842684,"width_in":"12.8\\"","name":"supersize_jpg","height_cm":"43.3 cm","height":5120,"display_name":"Super","human_readable_size":"4.6 MB","dpi":300,"format":"jpg"},"supersize_tiff":{"width":3840,"height_in":"17.1\\"","width_cm":"32.5 cm","size_in_bytes":58982400,"width_in":"12.8\\"","name":"supersize_tiff","height_cm":"43.3 cm","height":5120,"display_name":"Super","human_readable_size":"56.2 MB","dpi":300,"format":"tiff"},"small_jpg":{"width":375,"height_in":"9.3\\"","width_cm":"13.2 cm","size_in_bytes":184320,"width_in":"5.2\\"","name":"small_jpg","height_cm":"23.5 cm","height":666,"display_name":"Small","human_readable_size":"180 KB","dpi":72,"format":"jpg"}},"description":"Soup","keywords":["bread","dinner","laying","meal","oil","restaurant","soup","table"],"preview":{"width":337,"url":"http://ak.picdn.net/shutterstock/photos/500000/display_pic_with_logo/stock-photo-soup.jpg","height":450},"media_type":"photo","submitter_id":11875,"id":500000,"large_thumb":{"width":113,"url":"http://ak.picdn.net/shutterstock/photos/500000/thumb_large/stock-photo-soup.jpg","height":150},"small_thumb":{"width":75,"url":"http://ak.picdn.net/shutterstock/photos/500000/thumb_small/stock-photo-soup.jpg","height":100},"model_release_info":null}',
   '_rc' => 200,
   '_headers' => bless( {
                          'content-type' => 'application/json; charset=utf-8',
                          'x-powered-by' => 'Perl Dancer 1.3072',
                          'connection' => 'close',
                          'date' => 'Sun, 29 Apr 2012 22:43:45 GMT',
                          'content-length' => '2230',
                          'server' => 'nginx'
                        }, 'HTTP::Headers' ),
   '_msg' => 'OK',
   '_request' => bless( {
                          '_content' => '',
                          '_uri' => bless( do{\(my $o = 'http://media.dev.shuttercorp.net/library/shutterstock/photo/500000')}, 'URI::http' ),
                          '_headers' => bless( {}, 'HTTP::Headers' ),
                          '_method' => 'GET'
                        }, 'HTTP::Request' )
 }, 'HTTP::Response' )



 .......



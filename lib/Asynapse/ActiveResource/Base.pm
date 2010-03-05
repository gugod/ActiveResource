package Asynapse::ActiveResource::Base;
use Moose;
use MooseX::ClassAttribute;

use Lingua::EN::Inflect qw(PL);
use LWP::UserAgent;
use URI;
use XML::Hash;

class_has 'site' => (is => "rw", isa => "Str");
class_has 'user' => (is => "rw", isa => "Str");
class_has 'password' => (is => "rw", isa => "Str");

has 'field_attributes' => (is => "rw", isa => "HashRef");

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;
    my %args  = @_;

    $class->$orig(%args);
};

sub find {
    my ($class, $id) = @_;

    my $resource_name = PL lc $class;
    my $site = $class->site;
    my $user = $class->user;
    my $pass = $class->password;

    my $url  = "${site}/${resource_name}/${id}.xml";

    if ($user && $pass) {
        my $x = URI->new($url);
        $x->userinfo("${user}:${pass}");
        $url = "$x";
    }

    my $ua = LWP::UserAgent->new;
    my $request = HTTP::Request->new("GET", $url);
    my $response = $ua->request($request);
    unless ($response->is_success) {
        die "FAIL";
    }

    my $record = $class->new;
    $record->load_attributes_from_response( $response );
    return $record;
}

sub load_attributes_from_response {
    my $self = shift;
    my $response = shift;
    my $record_xml = $response->content;

    my $xc = XML::Hash->new();
    my $hash = $xc->fromXMLStringtoHash($record_xml);

    $self->field_attributes($hash);
}

sub AUTOLOAD {
    no strict;
    local $, = ", ";
    my $self = shift;
    my @args = @_;
    my $sub  = ${__PACKAGE__."::AUTOLOAD"};

    print STDERR "OHAI $sub: @_";
}


1;

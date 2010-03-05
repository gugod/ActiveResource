package Asynapse::ActiveResource::Base;
use Moose;
use MooseX::ClassAttribute;

class_has 'site' => (is => "rw", isa => "Str");
class_has 'user' => (is => "rw", isa => "Str");
class_has 'password' => (is => "rw", isa => "Str");

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;
    my %args  = @_;

    $class->$orig(%args);
};

use Lingua::EN::Inflect qw(PL);
use LWP::UserAgent;
use URI;

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

    my $record_xml = $response->content;
    print STDERR $record_xml;
    my $record = $class->new;
    return $record;
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

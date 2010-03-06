package ActiveResource::Base;
use Moose;
use MooseX::ClassAttribute;

use Lingua::EN::Inflect qw(PL);
use LWP::UserAgent;
use URI;
use XML::Hash;
use Hash::AsObject;

class_has 'site' => (is => "rw", isa => "Str");
class_has 'user' => (is => "rw", isa => "Str");
class_has 'password' => (is => "rw", isa => "Str");

has '_field_attributes' => (is => "rw", isa => "HashRef");

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
    my ($key, $value) = each %$hash;
    $self->_field_attributes($value);
    return $self;
}

sub AUTOLOAD {
    no strict;
    local $, = ", ";
    my $self = shift;
    my @args = @_;
    my ($sub) = ${__PACKAGE__."::AUTOLOAD"} =~ /::(.+?)$/;

    my $attr = $self->_field_attributes->{$sub};

    return $attr if !ref $attr;
    return $attr->{text} if $attr->{text};
    return Hash::AsObject->new($attr);
}


1;

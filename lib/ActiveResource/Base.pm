package ActiveResource::Base;
use common::sense;
use parent qw(Hash::AsObject Class::Data::Inheritable);
use LWP::UserAgent;
use Lingua::EN::Inflect qw(PL);
use URI;
use XML::Hash;

use namespace::clean;

__PACKAGE__->mk_classdata($_) for qw(site user password);

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
    my $response = $ua->get($url);
    unless ($response->is_success) {
        die "${class}->find FAIL. With HTTP Status: @{[ $response->status_line ]}\n";
    }

    my $record = $class->new;
    $record->load_attributes_from_response( $response );
    return $record;
}

sub create {
    print "XXX";
}

sub save {
    print "XXX";
}

sub AUTOLOAD {
    no strict;
    local $, = ", ";
    my $self = shift;
    my @args = @_;
    my ($sub) = ${__PACKAGE__."::AUTOLOAD"} =~ /::(.+?)$/;

    my $attr = $self->{_field_attributes}{$sub};

    return $attr if !ref $attr;
    return $attr->{text} if $attr->{text};
    return Hash::AsObject->new($attr);
}

sub collection_path {
    my ($class, $prefix_options, $query_options) = @_;
    my $resource_name = PL lc(ref($class) || $class);
    my $path = "/${resource_name}.xml";
    if ($prefix_options) {
        my ($k, $v) = each %$prefix_options;
        $k =~ s/_id$//s;
        my $prefix_resource_name = PL lc $k;
        $path = "/${prefix_resource_name}/${v}" . $path;
    }
    if ($query_options) {
        my $u = URI->new;
        $u->query_form(%$query_options);
        $path = $path . $u->as_string
    }
    return $path;
}

no namespace::clean;
# protected methods start from here

sub load_attributes_from_response {
    my $self = shift;
    my $response = shift;
    my $record_xml = $response->content;

    my $xc = XML::Hash->new();
    my $hash = $xc->fromXMLStringtoHash($record_xml);
    my ($key, $value) = each %$hash;
    $self->{_field_attributes} = $value;

    return $self;
}

# end of protected methods
use namespace::clean;

1;

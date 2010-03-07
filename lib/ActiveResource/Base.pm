package ActiveResource::Base;
use common::sense;
use parent qw(Class::Accessor::Lvalue::Fast Class::Data::Inheritable);
use Hash::AsObject;
use Lingua::EN::Inflect qw(PL);
use URI;
use ActiveResource::Connection;

__PACKAGE__->mk_classdata($_) for qw(site user password);
__PACKAGE__->mk_accessors(qw(attributes));

__PACKAGE__->mk_classdata(
    format => 'ActiveResource::Formats::XmlFormat'
);

__PACKAGE__->mk_classdata(
    connection => ActiveResource::Connection->new
);

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

    my $response = connection->get($url);
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

sub element_path {
    my ($class, $id, $prefix_options, $query_options) = @_;
    my $resource_name = PL lc(ref($class) || $class);
    my $path = "/${resource_name}/${id}.xml";
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

sub load {
    my ($self, $attr) = @_;
    my $a = {};
    while(my($name, $value) = each %$attr) {
        $a->{$name} = !ref($value) ? $value : $value->{text} || Hash::AsObject->new($value);
    }
    $self->attributes = $a;
    return $self;
}

sub encode {
    my ($self) = @_;
    $self->format->encode($self->attributes);
}

sub AUTOLOAD {
    no strict;
    local $, = ", ";
    my $self = shift;
    my @args = @_;
    my ($sub) = ${__PACKAGE__."::AUTOLOAD"} =~ /::(.+?)$/;

    if (@args == 1) {
        $self->attributes->{$sub} = ref($args[0]) ? $args[0] : { text => $args[0] };
        return $self;
    }

    my $attr = $self->attributes->{$sub};

    return $attr if !ref $attr;
    return $attr->{text} if $attr->{text};
    return Hash::AsObject->new($attr);
}

# protected methods start from here

sub load_attributes_from_response {
    my ($self, $response) = @_;

    my $record_xml = $response->content;
    my $hash = $self->format->decode($record_xml);
    my (undef, $attr) = each %$hash;

    $self->load($attr);
}

# end of protected methods

1;

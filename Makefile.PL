use inc::Module::Install;

all_from 'lib/ActiveResource.pm';

requies
    parent                 => 0,
    XML::Hash              => 0,
    Hash::AsObject         => 0,
    Moose                  => 0,
    MooseX::ClassAttribute => 0.13,
    LWP::UserAgent         => 0,
    Lingua::EN::Inflect    => 0,
    URI                    => 0;

tests 't/*.t';
authro_tests 'xt/*.t';

WriteAll;

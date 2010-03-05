use inc::Module::Install;

requies
    XML::Hash => 0,
    Hash::AsObject => 0,
    Moose => 0,
    MooseX::ClassAttribute => 0.13,
    LWP::UserAgent => 0,
    Lingua::EN::Inflect => 0,
    URI => 0;

WriteAll;

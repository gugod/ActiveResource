#!/usr/bin/env perl
package Stuff;
use Moose;
extends 'ActiveResource::Base';

package main;
use strict;
use Test::More;

subtest "Stuff" => sub {
    subtest "Class methods" => sub {
        for my $method (qw(new site user password find create)) {
            ok(Stuff->can($method), "There is a Stuff->$method");
        }

        done_testing;
    };

    subtest "Stuff->site is default to be the same as ActiveResource::Base->site" => sub {
        ActiveResource::Base->site("http://example.com");
        is(ActiveResource::Base->site, "http://example.com");
        is(Stuff->site, "http://example.com");

        done_testing;
    };

    subtest "Stuff->site can be overrided without effecting the value of ActiveResource::Base->site" => sub {
        Stuff->site("http://example2.com");
        ok(ActiveResource::Base->site ne Stuff->site);
        is(ActiveResource::Base->site, "http://example.com");
        is(Stuff->site, "http://example2.com");

        done_testing;
    };
};

done_testing;

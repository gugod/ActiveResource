#!/usr/bin/env perl
use strict;
use warnings;

package Issue;
use Moose;
extends 'Asynapse::ActiveResource::Base';

package main;
use Test::More;

for my $method (qw(site user password)) {
    ok(Issue->can($method));
}

done_testing;

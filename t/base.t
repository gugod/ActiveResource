#!/usr/bin/env perl
package Stuff;
use Moose;
extends 'ActiveResource::Base';

package main;
use strict;
use Test::More;

# Class methods
for my $method (qw(new site user password find create)) {
    ok(Stuff->can($method));
}

done_testing;

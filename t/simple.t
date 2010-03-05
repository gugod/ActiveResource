#!/usr/bin/env perl
use strict;
use warnings;
use Asynapse::ActiveResource::Base;

package Issue;
use Moose;
extends 'Asynapse::ActiveResource::Base';

Issue->site('http://localhost:3000');
Issue->user("gugod");
Issue->password("123aoe");

package main;
use Test::More;

my $issue = Issue->find(1);

is ref($issue), "Issue";

is $issue->id, 1;

# These should have defined values.
ok defined $issue->subject;
ok defined $issue->status->id;
ok defined $issue->status->name;

done_testing;

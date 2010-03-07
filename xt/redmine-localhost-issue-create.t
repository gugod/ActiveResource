#!/usr/bin/env perl
use common::sense;

package Issue;
use parent 'ActiveResource::Base';

__PACKAGE__->site("http://localhost:3000");
__PACKAGE__->user("admin");
__PACKAGE__->password("admin");

package main;
use Test::More;

my $issue = Issue->create(
    project_id => 1,
    subject => "Created from $$, " . __FILE__
);

like($issue->id, /^\d+$/);
like($issue->subject, /^Created from \d+,/);
is($issue->description, "Lipsum");

done_testing;

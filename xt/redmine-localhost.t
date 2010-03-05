#!/usr/bin/env perl
use Asynapse::ActiveResource::Base;

package Project;
use parent 'Asynapse::ActiveResource::Base';

package Issue;
use parent 'Asynapse::ActiveResource::Base';

package main;
use Test::More;

for(qw(Project Issue)) {
    $_->site("http://localhost:3000");
    $_->user("admin");
    $_->password("admin");
}

my $project = Project->find(1);
is $project->name, "test";

my $issue = Issue->find(1);
is $issue->id, 1;
is $issue->project->id, 1;
is $issue->project->name, "test";
is $issue->status->name, "Resolved";

ok $issue->can('save');

{
    local $TODO = "Feature: lvalue attribute setter and saving.";

    my $old_description = $issue->description;
    my $new_description = "Shiny new description. $$";
    $issue->description = $new_description;
    $issue->save;

    is $issue->description, $new_description;

    {
        my $i2 = Issue->find(1);
        is $i2->description, $new_description;
    }

    $issue->description = $old_description;
    $issue->save;

    is $issue->description, $new_description;
}

done_testing;

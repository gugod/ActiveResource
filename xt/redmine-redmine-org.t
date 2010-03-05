#!/usr/bin/env perl
use Asynapse::ActiveResource::Base;

package Project;
use Moose;
extends 'Asynapse::ActiveResource::Base';

package Issue;
use Moose;
extends 'Asynapse::ActiveResource::Base';

package main;
use Test::More;

Project->site("http://www.redmine.org");
Issue->site("http://www.redmine.org");

# http://www.redmine.org/projects/1
my $project = Project->find(1);
is $project->name, "Redmine";

# http://www.redmine.org/issues/1
my $issue = Issue->find(1);
is $issue->id, 1;
is $issue->project->id, 1;
is $issue->project->name, "Redmine";
is $issue->subject, "permissions if not admin";
is $issue->status->name, "Closed";

done_testing;

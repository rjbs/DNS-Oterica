#!/icg/bin/perl
use strict;
use warnings;
use Test::More;
use lib 't/lib';

use DNS::Oterica;
use DNS::Oterica::App;
use DNS::Oterica::Test;

my $dnso_root = 'eg';
my $dnso = new_ok 'DNS::Oterica::App', [ {
  root       => 'eg',
  hub_args   => {
    ns_family  => 'com.example.ns',
    hostmaster => 'hostmast@example.com',
  },
} ];

$dnso->populate_locations;
$dnso->populate_domains;
$dnso->populate_hosts;

my @locations = map { $_->as_data_lines } $dnso->hub->locations;
my @nodes = map { $_->as_data_lines } $dnso->hub->nodes;
my @node_families = map { $_->as_data_lines } $dnso->hub->node_families;

DNS::Oterica::Test->collect_dnso_nodes(@nodes);
DNS::Oterica::Test->collect_dnso_node_families(@node_families);

my $records = DNS::Oterica::Test->records;
ok(ref $records eq 'HASH', '$records is a hashref');

my @hosts = map { s[eg/hosts/][]; "$_.example.com" } glob 'eg/hosts/*';
my @domains = qw/lists.codesimply.com example.com foobox.com/;

ok(exists $records->{$_}{'+'}, "$_ has a + record") for @hosts;
ok(exists $records->{$_}{'Z'}, "$_ has a Z record") for @domains;

is_deeply(
  [ sort @locations ],
  [
    "%10.1:mc\n",
    "%10.2.0:mp\n",
  ],
  "location lines are as expected",
);

subtest "per-location IPs" => sub {
  my @azure_lines = grep {; /\A\+azure/ } @nodes;
  my @world_lines = grep {;   /:$/ } @azure_lines;
  my @other_lines = grep {; ! /:$/ } @azure_lines;

  is(@azure_lines, 2, "azure has 2 IPs");
  is(@world_lines, 1, "one is a world IP");
  is(@other_lines, 1, "one is not");
  like($world_lines[0], qr/10\.20\.0\.100/, "the non-world is 10.20.0.100");
  like($other_lines[0], qr/10\.2\.0\.2/,    "the non-world is 10.2.0.2");
};

done_testing;

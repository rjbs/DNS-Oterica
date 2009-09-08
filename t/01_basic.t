#!/icg/bin/perl
use strict;
use warnings;
use Test::Most;
use lib 't/lib';
use_ok('DNS::Oterica');
use_ok('DNS::Oterica::App');
use DNS::Oterica::Test;

my $dnso_root = 'eg';
my $dnso;
lives_and { $dnso = DNS::Oterica::App->new(root => 'eg'); is ref $dnso, 'DNS::Oterica::App'; }
  'constructor returns a DNSO object';

my @methods = qw(
  populate_domains
  populate_hosts
);

ok(ref $dnso->can($_) eq 'CODE', "DNSO object can $_") for @methods; 

lives_ok { $dnso->hub->add_location($_) } "can add $_->{name}" for (
  { name => 'quonix',      code => '',    network => '208.72.237.0/24',
    delegated => 1 },
  { name => 'fastnet',     code => '',    network => '128.200.30/24',   },
  { name => 'fastnet-dmz', code => '',    network => '192.168.10.0/24', },
  { name => 'sd',          code => '',    network => '64.74.157.0/25'   },
  { name => 'quonix-dmz',  code => 'qx',  network => '192.168.10.0/24'  },
  { name => 'office',      code => ''   },
);
lives_ok { $dnso->populate_domains($dnso_root) } "can populate domains";
lives_ok { $dnso->populate_hosts($dnso_root) } "can populate hosts";

my @nodes = map { $_->as_data_lines } $dnso->hub->nodes;
my @node_families = map { $_->as_data_lines } $dnso->hub->node_families;

DNS::Oterica::Test->collect_dnso_nodes(@nodes);
DNS::Oterica::Test->collect_dnso_node_families(@node_families);
my $records = DNS::Oterica::Test->records;
ok(ref $records eq 'HASH', '$records is a hashref');
my @hosts = map { s[eg/hosts/][]; "$_.example.com" } glob 'eg/hosts/*';
my @domains = map { s[eg/hosts/][] } glob 'eg/domains/*';
ok(exists $records->{$_}{'+'}, "$_ has a + record") for @hosts;
ok(exists $records->{$_}{'Z'}, "$_ has a Z record") for @domains;


done_testing;

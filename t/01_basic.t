#!/icg/bin/perl
use strict;
use warnings;
use Test::Most;
use lib 't/lib';
use_ok('DNS::Oterica');
use DNS::Oterica::Test;

my $dnso_root = 'eg';
my $dnso;
lives_and { $dnso = DNS::Oterica->new; is ref $dnso, 'DNS::Oterica'; }
  'constructor returns a DNSO object';

my @delegates = qw(
    add_location
    domain
    location
    host
    nodes
    node_family
    node_families
);

my @methods = qw(
  populate_domains
  populate_hosts
);

ok(ref $dnso->can($_) eq 'CODE', "DNSO object delegates $_") for @delegates; 
ok(ref $dnso->can($_) eq 'CODE', "DNSO object can $_") for @methods; 

lives_ok { $dnso->add_location($_) } "can add $_->{name}" for (
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

my @nodes = map { $_->as_data_lines } $dnso->nodes;
my @node_families = map { $_->as_data_lines } $dnso->node_families;

DNS::Oterica::Test->collect_dnso_nodes(@nodes);
DNS::Oterica::Test->collect_dnso_node_families(@node_families);
my $records = DNS::Oterica::Test->records;
ok(ref $records eq 'HASH', '$records is a hashref');


done_testing;

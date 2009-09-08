#!/icg/bin/perl
use strict;
use warnings;
use Test::Most;
use lib 't/lib';
use_ok('DNS::Oterica');

my $dnso_root = 'eg';
my $dnso;
lives_and { $dnso = DNS::Oterica->new; is ref $dnso, 'DNS::Oterica'; }
  'constructor returns a DNSO object';
$dnso->add_location($_) for (
  { name => 'quonix',      code => '',    network => '208.72.237.0/24',
    delegated => 1 },
  { name => 'fastnet',     code => '',    network => '128.200.30/24',   },
  { name => 'fastnet-dmz', code => '',    network => '192.168.10.0/24', },
  { name => 'sd',          code => '',    network => '64.74.157.0/25'   },
  { name => 'quonix-dmz',  code => 'qx',  network => '192.168.10.0/24'  },
  { name => 'office',      code => ''   },
);
$dnso->populate_domains($dnso_root);
$dnso->populate_hosts($dnso_root);

done_testing;

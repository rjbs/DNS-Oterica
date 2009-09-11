use strict;
use warnings;
package DNS::Oterica::RecordMaker::Diagnostic;
# ABSTRACT: a collector of record generation requests, for testing

use Sub::Install;

=head1 DESCRIPTION

This recordmaker returns hashrefs describing the requested record.

At present, the returned data are very simple.  They will change and improve
over time.

=cut

my @types = qw(
  comment
  a_and_ptr
  ptr
  soa_and_ns_for_ip
  a
  mx
  domain
  soa_and_ns
  cname
  txt
);

for my $type (@types) {
  my $code = sub {
    return {
      type => $type,
      args => [ @_ ],
    };
  };

  Sub::Install::install_sub({ code => $code, as => $type });
}

1;

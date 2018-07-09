package DNS::Oterica::Role::RecordMaker;
# ABSTRACT: a delegation class for the DNSO recordmaker.

use Moose::Role;

use DNS::Oterica::RecordMaker::TinyDNS;

=head1 DESCRIPTION

C<DNS::Oterica::Role::RecordMaker> delegates to an underlying record maker. It
exposes this record maker with its C<rec> method.

=attr rec

The record maker, e.g. L<DNS::Oterica::RecordMaker::TinyDNS>.

=cut

has rec => (
  is  => 'ro',
  isa => 'Defined', # String or object (duck type this?)
  default => sub { DNS::Oterica::RecordMaker::TinyDNS->new },
);

no Moose::Role;
1

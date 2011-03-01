package DNS::Oterica::Role::RecordMaker;
use Moose::Role;
# ABSTRACT: a delegation class for the DNSO recordmaker.

use DNS::Oterica::RecordMaker::TinyDNS;

=head1 DESCRIPTION

C<DNS::Oterica::Role::RecordMaker> delegates to an underlying record maker. It
exposes this record maker with its C<rec> method.

=attr rec

The record maker, e.g. L<DNS::Oterica::RecordMaker::TinyDNS>.

=cut

has rec => (
  is  => 'ro',
  isa => 'Str', # XXX or object doing role, etc
  default => 'DNS::Oterica::RecordMaker::TinyDNS',
);

no Moose::Role;
1

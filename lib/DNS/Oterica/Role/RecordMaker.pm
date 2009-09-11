package DNS::Oterica::Role::RecordMaker;
# ABSTRACT: a delegation class for the DNSO recordmaker.
use Moose::Role;

use DNS::Oterica::Util::RecordMaker;

=head1 DESCRIPTION

C<DNS::Oterica::Role::RecordMaker> delegates to an underlying record maker. It
exposes this record maker with its C<rec> method.

=attr rec

The record maker, e.g. L<DNS::Oterica::Util::RecordMaker>.

=cut

has rec => (
  is  => 'ro',
  isa => 'Str', # XXX or object doing role, etc
  default => 'DNS::Oterica::Util::RecordMaker',
);

no Moose::Role;
1

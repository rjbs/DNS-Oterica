package DNS::Oterica::Role::RecordMaker;
# ABSTRACT: a delegation class for the DNSO recordmaker.
use Moose::Role;

use DNS::Oterica::Util::RecordMaker;

=head1 DESCRIPTION

C<DNS::Oterica::Role::RecordMaker> delegates to an underlying record maker. It
exposes this record maker with its C<rec> method.

=head1 METHODS

=over 4

=item rec

Returns the record maker, e.g. L<DNS::Oterica::Util::RecordMaker>.

=cut

sub rec { 'DNS::Oterica::Util::RecordMaker' }

=item meta

Moose meta object.

=back

=cut


no Moose::Role;
1

package DNS::Oterica::Node::Domain;
# ABSTRACT: a FQDN node.
use Moose;
extends 'DNS::Oterica::Node';

with 'DNS::Oterica::Role::RecordMaker';

=head1 NAME

DNS::Oterica::Node::Domain -- A domain node.

=head1 DESCRIPTION

C<DNS::Oterica::Node::Domain> represents a domain name in DNS::Oterica. Domains
have hosts.

=head1 ATTRIBUTES

DNS::Oterica::Node::Host has these attributes. 

=over 4

=cut

=item fqdn

The fully qualified domain name for this domain.

=cut

sub fqdn {
  $_[0]->domain;
}

=item as_data_lines

Presently a no-op. Can be overridden to calculate nondefault data lines.

=cut

sub as_data_lines {
  return;
}

=item meta

Moose meta object.

=back

=cut

__PACKAGE__->meta->make_immutable;
no Moose;
1;

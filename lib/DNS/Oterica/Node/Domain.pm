package DNS::Oterica::Node::Domain;
# ABSTRACT: a domain node

use Moose;
extends 'DNS::Oterica::Node';

=head1 OVERVIEW

DNS::Oterica::Node::Domain represents a domain name in DNS::Oterica. Domains
have hosts.

=method fqdn

The fully qualified domain name for this domain.

=cut

sub fqdn { $_[0]->domain; }

__PACKAGE__->meta->make_immutable;
no Moose;
1;

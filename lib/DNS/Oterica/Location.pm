package DNS::Oterica::Location;
# ABSTRACT: a location at which hosts may reside
use Moose;

use Net::IP;
use Moose::Util::TypeConstraints;

# TODO: move these to a types library
subtype 'DNS::Oterica::Type::Network'
  => as Object
  => where { $_->isa('Net::IP') };

coerce 'DNS::Oterica::Type::Network'
  => from 'Str'
  => via { Net::IP->new($_) };

=head1 OVERVIEW

Locations are network locations where hosts may be found.  They represent
unique IP ranges with unique names.

Like other DNS::Oterica objects, they should be created through the hub.

=attr name

This is the location's unique name.

=cut

has name => (is => 'ro', isa => 'Str', required => 1);

=attr network

This is the C<Net::IP> range for the network at this location.

=cut

has 'network' => (
  is   => 'ro',
  isa  => 'DNS::Oterica::Type::Network',
  required => 0,
  coerce   => 1,
);

sub BUILD {
  my ($self) = @_;
  my $network = $self->network;
  unless (grep { $_ == $network->prefixlen } qw(0 8 16 24 32)) {
    confess("non-power-of-two network length");
  }
}

# Do we really want to keep this?
has delegated => (is => 'ro', isa => 'Bool', required => 0, default => 0);

has code => (is => 'ro', isa => 'Str', required => 1);

__PACKAGE__->meta->make_immutable;
no Moose;
1;

package DNS::Oterica::Network;
# ABSTRACT: a network to which results are served
use Moose;

use Net::IP;
use Moose::Util::TypeConstraints;

# TODO: move these to a types library
subtype 'DNS::Oterica::Type::Network'
  => as Object
  => where { $_->isa('Net::IP') };

coerce 'DNS::Oterica::Type::Network'
  => from 'Str'
  => via { Net::IP->new($_) || confess( Net::IP::Error() ) };

=head1 OVERVIEW

Networks are IP networks to which results are served, and can be used to
implement split horizons.

Like other DNS::Oterica objects, they should be created through the hub.

=attr name

This is the network's unique name.

=cut

has name => (is => 'ro', isa => 'Str', required => 1);

=attr subnet

This is the C<Net::IP> range for the network at this network.

=cut

has subnet => (
  is   => 'ro',
  isa  => 'DNS::Oterica::Type::Network',
  required => 1,
  coerce   => 1,
);

sub _class_prefixes {
  my ($self, $ip) = @_; # $ip arg for testing

  $ip ||= $self->subnet;
  my $pl    = $ip->prefixlen;
  my $class = int( $pl / 8 );
  my @quads = split /\./, $ip->ip;
  my @keep  = splice @quads, 0, $class;
  my $fixed = join q{.}, @keep;
  my $bits  = 8 - ($pl - $class * 8);

  return $fixed if $bits == 8;

  my @prefixes = map {; "$fixed.$_" } (0 .. (2**$bits - 1));
  return @prefixes;
}

sub as_data_lines {
  my ($self) = @_;
  $self->hub->rec->location($self);
}

# Do we really want to keep this?
has delegated => (is => 'ro', isa => 'Bool', required => 0, default => 0);

has code => (is => 'ro', isa => 'Str', required => 1);

with 'DNS::Oterica::Role::HasHub';

__PACKAGE__->meta->make_immutable;
no Moose;
1;

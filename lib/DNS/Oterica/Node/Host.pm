package DNS::Oterica::Node::Host;
# ABSTRACT: a host node, i.e., an individual subdomain
use Moose;
extends 'DNS::Oterica::Node';

=head1 NAME

DNS::Oterica::Node::Host -- A host node.

=head1 DESCRIPTION

C<DNS::Oterica::Node::Host> represents an individual machine in DNS::Oterica.
A node has interfaces (which have IP addresses), a physical location (a
datacenter, etc.), and a C<DNS::Oterica::Node::Domain>.

=head1 ATTRIBUTES

DNS::Oterica::Node::Host has these attributes. 

=over 4

=cut

=item hostname: readonly required string

This host's Internet name.

=cut

has hostname => (is => 'ro', isa => 'Str', required => 1);

=item aliases: readonly required arrayref

The Internet host name aliases for this host.

=cut

has aliases  => (
  is => 'ro',
  isa => 'ArrayRef',
  required   => 1,
  auto_deref => 1,
  default    => sub { [] },
);

=item interfaces: readonly required arrayref

A tuple of (IP, location) pairs. 

=cut

# each one is [ $ip, $loc ]
has interfaces => (
  is  => 'ro',
  isa => 'ArrayRef',
  required   => 1,
  auto_deref => 1,
);

=item location: readonly required string

The physical location (datacenter, etc.) of this host.

=cut

has location => (is => 'ro', isa => 'Str', required => 1);

=item world_ip: readonly calculated string

The C<world> location IP address for this host.

=cut

sub world_ip {
  my ($self) = @_;
  my ($if) = grep { $_->[1]->name eq 'world' } $self->interfaces;
  $if->[0];
}

=item fqdn: readonly calculated string

The fully-qualified domain name of this host.


=cut

sub fqdn {
  my ($self) = @_;
  sprintf '%s.%s', $self->hostname, $self->domain;
}

=item meta

Moose meta object.

=cut

=back

=head1 METHODS

=over 4

=item as_data_lines

Generates A records for this hostname and all of its aliases, and generates SOA
and NS records for all of this node's IP addresses.

=back

=cut

sub _family_names {
  my ($self) = @_;
  my @all_families = $self->hub->node_families;
  my @has_self = grep { grep { $_ == $self } $_->nodes } @all_families;

  return map { $_->name } @has_self;
}

sub as_data_lines {
  my ($self) = @_;

  my @lines = $self->rec->comment("begin host ". $self->fqdn);

  push @lines, $self->rec->comment(
    "  families: " . join(q{, }, $self->_family_names)
  );

  push @lines, $self->rec->a_and_ptr({ name => $self->fqdn, node => $self });
  push @lines, $self->rec->a({ name => $_, node => $self }) for $self->aliases;

  push @lines, $self->rec->comment("end host ". $self->fqdn . "\n");

  return @lines;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

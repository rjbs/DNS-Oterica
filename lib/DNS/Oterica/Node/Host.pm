package DNS::Oterica::Node::Host;
# ABSTRACT: a host node

use Moose;
extends 'DNS::Oterica::Node';

=head1 OVERVIEW

C<DNS::Oterica::Node::Host> represents an individual machine in DNS::Oterica.
A node has interfaces (which have IP addresses) and is part of a named domain.

=attr hostname

This is the name of the host.  B<It does not include the domain name.>

=cut

has hostname => (is => 'ro', isa => 'Str', required => 1);

=attr aliases

This is an arrayref of other fully-qualified names that refer to this host.

The accessor returns a list.

=cut

has aliases  => (
  isa => 'ArrayRef',
  required => 1,
  default  => sub { [] },
  traits   => [ 'Array' ],
  handles  => {
    aliases => 'elements',
  },
);

=attr interfaces

This is an arrayref of pairs, each one an IP address and a network.

This attribute is pretty likely to change later.

=cut

has interfaces => (
  isa => 'ArrayRef',
  required => 1,
  traits   => [ 'Array' ],
  handles  => {
    interfaces => 'elements',
  },
);

=attr location

The name of the network location of this host

=cut

has location => (is => 'ro', isa => 'Str', required => 1);

=attr ttl

This is the default TTL for the host's A records -- it doesn't affect the TTL
for records created by families to which the host belongs.  If not provided,
it will be unset, and the default TTL is used.

=cut

has ttl => (is => 'ro', isa => 'Int');

=method fqdn

This is the fully-qualified domain name of this host.

=cut

sub fqdn {
  my ($self) = @_;
  sprintf '%s.%s', $self->hostname, $self->domain;
}

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

  push @lines, $self->rec->a_and_ptr({
    name => $self->fqdn,
    node => $self,
    ttl  => scalar $self->ttl,
  });

  for ($self->aliases) {
    push @lines, $self->rec->a({
      name => $_,
      node => $self,
      ttl  => scalar $self->ttl,
    });
  }

  push @lines, $self->rec->comment("end host ". $self->fqdn . "\n");

  return @lines;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

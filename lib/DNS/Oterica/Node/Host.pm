package DNS::Oterica::Node::Host;
# ABSTRACT: a host node
use Moose;
extends 'DNS::Oterica::Node';

=head1 OVERVIEW

C<DNS::Oterica::Node::Host> represents an individual machine in DNS::Oterica.
A node has interfaces (which have IP addresses), a network location, and is
part of a named domain.

=attr hostname

This is the name of the host.  B<It does not include the domain name.>

=cut

has hostname => (is => 'ro', isa => 'Str', required => 1);

=attr aliases

This is an arrayref of other fully-qualified names that refer to this host.

=cut

has aliases  => (
  is => 'ro',
  isa => 'ArrayRef',
  required   => 1,
  auto_deref => 1,
  default    => sub { [] },
);

=attr interfaces

This is an arrayref of pairs, each one an IP address and a location.

This attribute is pretty likely to change later.

=cut

has interfaces => (
  is  => 'ro',
  isa => 'ArrayRef',
  required   => 1,
  auto_deref => 1,
);

=item location

The name of the network location of this host

=cut

has location => (is => 'ro', isa => 'Str', required => 1);

=method world_ip

The C<world> location IP address for this host.

=cut

sub world_ip {
  my ($self) = @_;
  my ($if) = grep { $_->[1]->name eq 'world' } $self->interfaces;
  $if->[0];
}

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

  push @lines, $self->rec->a_and_ptr({ name => $self->fqdn, node => $self });
  push @lines, $self->rec->a({ name => $_, node => $self }) for $self->aliases;

  push @lines, $self->rec->comment("end host ". $self->fqdn . "\n");

  return @lines;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

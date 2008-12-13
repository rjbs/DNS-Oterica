package DNS::Oterica::Node::Host;
use Moose;
extends 'DNS::Oterica::Node';

has hostname => (is => 'ro', isa => 'Str', required => 1);
has aliases  => (
  is => 'ro',
  isa => 'ArrayRef',
  required   => 1,
  auto_deref => 1,
  default    => sub { [] },
);

# each one is [ $ip, $loc ]
has interfaces => (
  is  => 'ro',
  isa => 'ArrayRef',
  required   => 1,
  auto_deref => 1,
);

has location => (is => 'ro', isa => 'Str', required => 1);

sub world_ip {
  my ($self) = @_;
  my ($if) = grep { $_->[1]->name eq 'world' } $self->interfaces;
  $if->[0];
}

sub fqdn {
  my ($self) = @_;
  sprintf '%s.%s', $self->hostname, $self->domain;
}

sub as_data_lines {
  my ($self) = @_;
  my @lines = $self->rec->a_and_ptr({ name => $self->fqdn, node => $self });
  push @lines, $self->rec->a({ name => $_, node => $self }) for $self->aliases;

  return @lines;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

package DNS::Oterica::Node;
use Moose;

has name   => (is => 'ro', isa => 'Str', required => 1);
has domain => (is => 'ro', isa => 'Str', required => 1);
has roles  => (is => 'ro', isa => 'ArrayRef', default => sub { [] });

# each one is [ $ip, $loc ]
has interfaces => (
  is  => 'ro',
  isa => 'ArrayRef',
  required   => 1,
  auto_deref => 1,
);

# has ip       => (is => 'ro', isa => 'Str', required => 1);
has location => (is => 'ro', isa => 'Str', required => 1);

sub world_ip {
  my ($self) = @_;
  my ($if) = grep { $_->[1]->name eq 'world' } $self->interfaces;
  $if->[0];
}

with 'DNS::Oterica::Role::RecordMaker';

sub add_to_role {
  my ($self, $role) = @_;
  $role->add_node($self);
  push @{ $self->roles }, $role;
}

sub fqdn {
  my ($self) = @_;
  sprintf '%s.%s', $self->name, $self->domain;
}

sub as_data_lines {
  my ($self) = @_;
  $self->rec->a_and_ptr({ name => $self->fqdn, node => $self });
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

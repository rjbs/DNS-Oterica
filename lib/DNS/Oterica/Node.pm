package DNS::Oterica::Node;
use Moose;

with 'DNS::Oterica::Role::RecordMaker';

has domain => (is => 'ro', isa => 'Str', required => 1);
has roles  => (is => 'ro', isa => 'ArrayRef', default => sub { [] });

has hub => (
  is  => 'ro',
  isa => 'DNS::Oterica::Hub',
  required => 1,
  weak_ref => 1,
);

sub add_to_role {
  my ($self, $role) = @_;
  $role = $self->hub->node_role($role) unless ref $role;
  return if $self->does_node_role($role);
  $role->add_node($self);
  push @{ $self->roles }, $role;
}

sub does_node_role {
  my ($self, $role) = @_;
  $role = $self->hub->node_role($role) unless ref $role;

  for my $node_role (@{ $self->roles }) {
    return 1 if $role == $node_role;
  }

  return;
}

sub as_data_lines {
  return;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

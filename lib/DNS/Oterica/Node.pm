package DNS::Oterica::Node;
use Moose;

with 'DNS::Oterica::Role::RecordMaker';

has domain   => (is => 'ro', isa => 'Str', required => 1);
has families => (is => 'ro', isa => 'ArrayRef', default => sub { [] });

has hub => (
  is  => 'ro',
  isa => 'DNS::Oterica::Hub',
  required => 1,
  weak_ref => 1,
);

sub add_to_family {
  my ($self, $family) = @_;
  $family = $self->hub->node_family($family) unless ref $family;
  return if $self->in_node_family($family);
  $family->add_node($self);
  push @{ $self->families }, $family;
}

sub in_node_family {
  my ($self, $family) = @_;
  $family = $self->hub->node_family($family) unless ref $family;

  for my $node_family (@{ $self->families }) {
    return 1 if $family == $node_family;
  }

  return;
}

sub as_data_lines {
  return;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

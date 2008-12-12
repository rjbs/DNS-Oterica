package DNS::Oterica::NodeRole;
use Moose;

has name  => (is => 'ro', isa => 'Str', required => 1);

has nodes => (
  is  => 'ro',
  isa => 'ArrayRef',
  init_arg => undef,
  default  => sub { [] },
);

sub add_node {
  my ($self, $node) = @_;
  push @{ $self->nodes }, $node;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

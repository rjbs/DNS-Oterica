package DNS::Oterica::NodeRole;
use Moose;

with 'DNS::Oterica::Role::RecordMaker';

has nodes => (
  is  => 'ro',
  isa => 'ArrayRef',
  auto_deref => 1,
  init_arg   => undef,
  default    => sub { [] },
);

sub add_node {
  my ($self, $node) = @_;
  push @{ $self->nodes }, $node;
}

sub as_data_lines {
  my ($self) = @_;
  my $string = "# begin role " . $self->name . "\n";
  $string .= $_ for inner();
  $string .= "# end role " . $self->name . "\n";

  return $string;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

package DNS::Oterica::NodeFamily;
use Moose;

with 'DNS::Oterica::Role::RecordMaker';

has hub => (
  is   => 'ro',
  isa  => 'DNS::Oterica::Hub',
  weak_ref => 1,
  required => 1,
);

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
  my $string = "# begin family " . $self->name . "\n";
  $string .= $_ for inner();
  $string .= "# end family " . $self->name . "\n";

  return $string;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

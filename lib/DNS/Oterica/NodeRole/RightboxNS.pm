package DNS::Oterica::NodeRole::RightboxNS;
use Moose;
extends 'DNS::Oterica::NodeRole';

sub name { 'com.rightbox.ns' }

has ns_nodes => (
  is  => 'ro',
  isa => 'HashRef',
  default    => sub { {} },
  auto_deref => 1,
);

after add_node => sub {
  my ($self, $node) = @_;
  my $nodes = $self->ns_nodes;
  my $i = keys %$nodes;
  
  my $next_name = sprintf 'ns-%s.rightbox.com', $i+1;

  $self->ns_nodes->{ $next_name } = $node;
};

augment as_data_lines => sub {
  my ($self) = @_;
  my @lines;

  my %ns = $self->ns_nodes;
  for my $name (sort keys %ns) {
    push @lines, $self->rec->a({
      name => $name,
      node => $ns{$name},
    });
  }

  return @lines;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

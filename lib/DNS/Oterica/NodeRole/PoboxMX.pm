package DNS::Oterica::NodeRole::PoboxMX;
use Moose;
extends 'DNS::Oterica::NodeRole';

sub name { 'com.pobox.mx' }

has mx_nodes => (
  is  => 'ro',
  isa => 'HashRef',
  default    => sub { {} },
  auto_deref => 1,
);

after add_node => sub {
  my ($self, $node) = @_;
  my $nodes = $self->mx_nodes;
  my $i = keys %$nodes;
  
  my $next_name = sprintf 'mx-%s.pobox.com', $i+1;

  $self->mx_nodes->{ $next_name } = $node;
};

augment as_data_lines => sub {
  my ($self) = @_;
  my @lines;

  my $i = 1;

  my @required = map { "$_.pobox.com" } qw(mx-pa-3 mx-ca-1 mx-ca-2 mx-ca-3);

  my @nodes = $self->nodes;
  while (my $stupid_mx = shift @required) {
    my $next = shift @nodes;
    push @lines, $self->rec->a({
      name => $stupid_mx,
      node => $next,
    });
    push @nodes, $next;
  }

  my %mx = $self->mx_nodes;
  for my $name (sort keys %mx) {
    push @lines, $self->rec->a({
      name => $name,
      node => $mx{$name},
    });
  }

  return @lines;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

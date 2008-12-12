package DNS::Oterica::NodeRole::ListboxVDom;
use Moose;
extends 'DNS::Oterica::NodeRole';

sub name { 'com.listbox.vdom' }

augment as_data_lines => sub {
  my ($self) = @_;
  my @lines;

  my $i = 1;

  my %mx_nodes = $self->hub->node_role('com.listbox.mx')->mx_nodes;

  for my $node ($self->nodes) {
    for my $mx (keys %mx_nodes) {
      push @lines, $self->rec->mx({
        name => $node->fqdn,
        mx   => $mx,
        node => $mx_nodes{$mx},
      });
    }
  }

  return @lines;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

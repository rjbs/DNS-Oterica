package DNS::Oterica::NodeRole::RightboxDomain;
use Moose;
extends 'DNS::Oterica::NodeRole';

sub name { 'com.rightbox.domain' }

augment as_data_lines => sub {
  my ($self) = @_;
  my @lines;

  my %ns_nodes = $self->hub->node_role('com.rightbox.ns')->ns_nodes;

  for my $node ($self->nodes) {
    for my $ns (keys %ns_nodes) {
      push @lines, $self->rec->domain({
        domain => $node->fqdn,
        ns     => $ns,
      });
    }
  }

  return @lines;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

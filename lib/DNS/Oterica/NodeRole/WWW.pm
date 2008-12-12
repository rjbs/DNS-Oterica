package DNS::Oterica::NodeRole::WWW;
use Moose;
extends 'DNS::Oterica::NodeRole';

sub name { 'com.pobox.www' }

augment as_data_lines => sub {
  my ($self) = @_;

  my $string = '';
  for my $node ($self->nodes) {
    $string .= $self->rec->a({
      name => 'www.pobox.com',
      ip   => $node->ip,
    });
  }

  return $string;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

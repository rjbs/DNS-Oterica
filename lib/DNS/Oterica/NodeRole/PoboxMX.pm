package DNS::Oterica::NodeRole::PoboxMX;
use Moose;
extends 'DNS::Oterica::NodeRole';

sub name { 'com.pobox.mx' }

augment as_data_lines => sub {
  my ($self) = @_;
  my @lines;

  my $i = 1;

  my @required = map { "$_.pobox.com" } qw(mx-pa-3 mx-ca-1 mx-ca-2 mx-ca-3);

  for my $node ($self->nodes) {
    if (my $stupid_mx = shift @required) {
      push @lines, $self->rec->a({
        name => $stupid_mx,
        ip   => $node->ip,
      });
    }

    my $mx_name = sprintf 'mx-%s.pobox.com', $i++;
    push @lines, $self->rec->a({
      name => $mx_name,
      ip   => $node->ip,
    });
  }

  return @lines;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

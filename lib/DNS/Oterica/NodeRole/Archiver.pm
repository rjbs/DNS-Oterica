package DNS::Oterica::NodeRole::Archiver;
use Moose;
extends 'DNS::Oterica::NodeRole';

sub name { 'com.listbox.archiver' }

augment as_data_lines => sub {
  my ($self) = @_;
  my @lines;

  for my $node ($self->nodes) {
    for my $name (
      qw(*.archive.listbox.com *.archives.listbox.com trampoline.listbox.com)
    ) {
      push @lines, $self->rec->mx({
        name => $name,
        mx   => $node->fqdn,
        node => $node,
      });
    }

    push @lines, $self->rec->a({
      name => 'www.archives.listbox.com',
      node => $node,
    });
  }

  return @lines;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

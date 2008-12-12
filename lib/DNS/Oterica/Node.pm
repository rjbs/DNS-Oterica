package DNS::Oterica::Node;
use Moose;

with 'DNS::Oterica::Role::RecordMaker';

has domain   => (is => 'ro', isa => 'Str', required => 1);
has roles    => (is => 'ro', isa => 'ArrayRef', default => sub { [] });

sub add_to_role {
  my ($self, $role) = @_;
  $role->add_node($self);
  push @{ $self->roles }, $role;
}

sub fqdn {
  $_[0]->domain;
}

sub as_data_lines {
  return;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

package DNS::Oterica::Node;
use Moose;

has name   => (is => 'ro', isa => 'Str', required => 1);
has domain => (is => 'ro', isa => 'Str', required => 1);
has roles  => (is => 'ro', isa => 'ArrayRef', default => sub { [] });

has ip       => (is => 'ro', isa => 'Str', required => 1);
has location => (is => 'ro', isa => 'Str', required => 1);

with 'DNS::Oterica::Role::RecordMaker';

sub add_to_role {
  my ($self, $role) = @_;
  $role->add_node($self);
  push @{ $self->roles }, $role;
}

sub fqdn {
  my ($self) = @_;
  sprintf '%s.%s', $self->name, $self->domain;
}

sub as_data_lines {
  my ($self) = @_;
  $self->rec->a_and_ptr({ name => $self->fqdn, ip => $self->ip });
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

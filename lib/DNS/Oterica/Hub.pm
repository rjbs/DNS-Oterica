package DNS::Oterica::Hub;
use Moose;
# use MooseX::AttributeHelpers;

use DNS::Oterica::Location;
use DNS::Oterica::Node;
use DNS::Oterica::NodeRole;

has locations => (
  is  => 'ro',
  isa => 'ArrayRef[DNS::Oterica::Location]',
  # metaclass  => 'Collection::Array',
  # provides   => { push => 'add_location' },
  auto_deref => 1,
  init_arg   => undef,
  default    => sub { [] },
);

has [ qw(_domain_registry _node_role_registry) ] => (
  is  => 'ro',
  isa => 'HashRef',
  init_arg => undef,
  default  => sub { {} },
);

use Module::Pluggable
  search_path => [ qw(DNS::Oterica::NodeRole) ],
  require     => 1;

sub BUILD {
  my ($self) = @_;
  $self->_node_role_registry->{ $_->name } = $_->new for $self->plugins;
}

sub domain {
  my ($self, $name) = @_;
  return $self->_domain_registry->{$name} ||= {};
}

sub node {
  my ($self, $domain_name, $name, $arg) = @_;
  my $domain = $self->domain($domain_name);

  confess "tried to create $name . $domain_name twice"
    if $domain->{$name} and $arg;

  return $domain->{$name} = DNS::Oterica::Node->new({
    domain => $domain_name,
    name   => $name,
    %$arg,
  });
}

sub nodes {
  my ($self) = @_;

  my @nodes;

  for my $domain (values %{ $self->_domain_registry }) {
    push @nodes, values %$domain;
  }

  return @nodes;
}

sub node_role {
  my ($self, $name) = @_;

  return $self->_node_role_registry->{$name} || confess "unknown role $name";
}

sub node_roles {
  my ($self) = @_;
  return values %{ $self->_node_role_registry };
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

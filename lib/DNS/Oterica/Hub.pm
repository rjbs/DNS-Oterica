package DNS::Oterica::Hub;
# ABSTRACT: DNSO hub. has locations and node families.
use Moose;
# use MooseX::AttributeHelpers;

use DNS::Oterica::Location;
use DNS::Oterica::Node;
use DNS::Oterica::Node::Domain;
use DNS::Oterica::Node::Host;
use DNS::Oterica::NodeFamily;

has [ qw(_domain_registry _loc_registry _node_family_registry) ] => (
  is  => 'ro',
  isa => 'HashRef',
  init_arg => undef,
  default  => sub { {} },
);

use Module::Pluggable
  search_path => [ qw(DNS::Oterica::NodeFamily) ],
  require     => 1;

sub BUILD {
  my ($self) = @_;

  for my $plugin ($self->plugins) {
    confess "tried to register " . $plugin->name . " twice" if exists
      $self->_node_family_registry->{$plugin->name};
    $self->_node_family_registry->{ $plugin->name }
        = $plugin->new({ hub => $self });
  }

  $self->_loc_registry->{world} = DNS::Oterica::Location->new({
    name => 'world',
    code => '',
  });
}

sub domain {
  my ($self, $name, $arg) = @_;
  my $domreg = $self->_domain_registry;

  confess "tried to create domain $name twice" if $domreg->{$name} and $arg;

  return $domreg->{$name} ||= DNS::Oterica::Node::Domain->new({
    domain => $name,
    %{ $arg || {} },
    hub    => $self,
  });
}

sub location {
  my ($self, $name) = @_;
  return $self->_loc_registry->{$name} || confess "no such location '$name'";
}

sub add_location {
  my ($self, $arg) = @_;
  my $loc = DNS::Oterica::Location->new({ %$arg, hub => $self });

  my $name = $loc->name;
  confess "tried to create $name twice" if $self->_loc_registry->{$name};

  $self->_loc_registry->{$name} = $loc;
}

sub host {
  my ($self, $domain_name, $name, $arg) = @_;
  my $domain = $self->domain($domain_name);

  confess "tried to create $name . $domain_name twice"
    if $domain->{$name} and $arg;

  return $domain->{nodes}{$name} ||= DNS::Oterica::Node::Host->new({
    domain   => $domain_name,
    hostname => $name,
    %$arg,
    hub      => $self,
  });
}

sub nodes {
  my ($self) = @_;

  my @nodes;

  for my $domain (values %{ $self->_domain_registry }) {
    push @nodes, values %{ $domain->{nodes} || {} };
  }

  return @nodes;
}

sub node_family {
  my ($self, $name) = @_;

  return $self->_node_family_registry->{$name}
      || confess "unknown family $name";
}

sub node_families {
  my ($self) = @_;
  return values %{ $self->_node_family_registry };
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

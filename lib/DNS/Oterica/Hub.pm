package DNS::Oterica::Hub;
# ABSTRACT: the center of control for a DNS::Oterica system

use Moose;
with 'DNS::Oterica::Role::RecordMaker';

# use MooseX::AttributeHelpers;

use DNS::Oterica::Location;
use DNS::Oterica::Node;
use DNS::Oterica::Node::Domain;
use DNS::Oterica::Node::Host;
use DNS::Oterica::NodeFamily;

=head1 OVERVIEW

The hub is the central collector of DNS::Oterica data.  All new entries are
given to the hub to collect.  The hub takes care of preventing duplicates and
keeping data synchronized.

=cut

has [ qw(_domain_registry _loc_registry _node_family_registry) ] => (
  is  => 'ro',
  isa => 'HashRef',
  init_arg => undef,
  default  => sub { {} },
);

=attr ns_family

This is the name of the family whose hosts will be used for NS records for
hosts and in SOA lines.

=cut

has ns_family => (
  is  => 'ro',
  isa => 'Str',
  required => 1,
);

=attr hostmaster

This is the email address to be used as the contact point in SOA lines.

=cut

has hostmaster => (
  is  => 'ro',
  isa => 'Str',
  required => 1,
);

sub soa_rname {
  my ($self) = @_;
  my $addr = $self->hostmaster;
  $addr =~ s/@/./;
  return $addr;
}

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

  $self->add_location({
    name => 'world',
    code => 'WW',
    network => '0.0.0.0/0',
  });

  $self->add_location({
    name => 'always-visible',
    code => '',
    network => '0.0.0.0/32',
  });
}

=method domain

  my $new_domain = $hub->domain($name => \%arg);

  my $domain = $hub->domain($name);

This method will return a domain found by name, or if C<\%arg> is given, will
create a new domain.

If no domain is found and C<\%arg> is not given, an exception is raised.

If C<\%arg> is given for a domain that already exists, an exception is raised.

=cut

sub domain {
  my ($self, $name, $arg) = @_;
  my $domreg = $self->_domain_registry;

  confess "tried to create domain $name twice" if $domreg->{$name} and $arg;

  # XXX: This should be possible to do. -- rjbs, 2009-09-11
  # confess "no such domain: $name" if ! defined $arg and ! $domreg->{$name};

  return $domreg->{$name} ||= DNS::Oterica::Node::Domain->new({
    domain => $name,
    %{ $arg || {} },
    hub    => $self,
  });
}

=method location

  my $loc = $hub->location($name);

This method finds the named location and returns it.  If no location for the
given name is registered, an exception is raised.

=cut

sub location {
  my ($self, $name) = @_;
  return $self->_loc_registry->{$name} || confess "no such location '$name'";
}

=method locations

  my @loc = $hub->locations;

=cut

sub locations {
  my ($self) = @_;
  return values %{ $self->_loc_registry };
}

=method add_location

  my $loc = $hub->add_location(\%arg);

This registers a new location, raising an exception if one already exists for
the given name.

=cut

sub add_location {
  my ($self, $arg) = @_;

  my $loc = DNS::Oterica::Location->new({ %$arg, hub => $self });

  my $name = $loc->name;
  confess "tried to create $name twice" if $self->_loc_registry->{$name};

  my $code = $loc->code;
  my $net  = $loc->network;

  my @errors;
  for my $existing ($self->locations) {
    if ($loc->code eq $existing->code) {
      push @errors, sprintf "code '%s' conflicts with location %s",
        $code, $existing->name;
    }

    next if $existing->name eq 'always-visible';

    if ($net->overlaps($existing->network) == $Net::IP::IP_IDENTICAL) {
      push @errors, sprintf "network '%s' conflicts with location %s (%s)",
        $net->ip, $existing->name, $existing->network->ip;
    }
  }

  if (@errors) {
    confess("errors registering location $name: " . join q{; }, @errors);
  }

  $self->_loc_registry->{$name} = $loc;
}

=method host

  my $host = $hub->host($domain_name, $hostname);

  my $new_host = $hub->host($domain_name, $hostname, \%arg);

This method will find or create a host, much like the C<L</domain>> method.

=cut

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

=method nodes

This method will return a list of all nodes registered with the system.

B<Warning>: at present this will return only hosts.

=cut

sub nodes {
  my ($self) = @_;

  my @nodes;

  for my $domain (values %{ $self->_domain_registry }) {
    push @nodes, values %{ $domain->{nodes} || {} };
  }

  return @nodes;
}

=method node_family

  my $family = $hub->node_family($family_name);

This method will return the named familiy.  If no such family exists, an
exception will be raised.

=cut

sub node_family {
  my ($self, $name) = @_;

  return $self->_node_family_registry->{$name}
      || confess "unknown family $name";
}

=method node_families

  my @families = $hub->node_families;

This method will return all node families.  (These are set up during hub
initialization.)

=cut

sub node_families {
  my ($self) = @_;
  return values %{ $self->_node_family_registry };
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

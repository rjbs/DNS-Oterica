package DNS::Oterica::App;
# ABSTRACT: the code behind `dnsoterica`

use Moose;
use DNS::Oterica::Hub;
use File::Find::Rule;
use YAML::XS ();

=attr hub

This is the L<DNS::Oterica::Hub> into which entries will be loaded.

=cut

has hub => (
  is   => 'ro',
  isa  => 'DNS::Oterica::Hub',
  writer    => '_set_hub',
  predicate => '_has_hub',
);

sub BUILD {
  my ($self, $arg) = @_;

  confess "both hub and hub_args provided"
    if $self->_has_hub and $arg->{hub_args};

  unless ($self->_has_hub) {
    my %args = %{$arg->{hub_args}};
    $self->_set_hub( DNS::Oterica::Hub->new(\%args || {}) );
    if (my $location_root = delete $arg->{location_root}) {
      my @locs = map { YAML::XS::LoadFile $_ } glob "$location_root/*";
      $self->hub->add_location($_) for @locs;
    }
  }
}

=attr root

This is a directory in which F<dnsoterica> will look for configuration files.

It will look in the subdirectory F<domains> for domain definitions and F<hosts>
for hosts.

=cut

has root => (
  is       => 'ro',
  required => 1,
);

sub populate_domains {
  my ($self) = @_;
  my $root = $self->root;
  for my $file (File::Find::Rule->file->in("$root/domains")) {
    for my $data (YAML::XS::LoadFile($file)) {
      my $node = $self->hub->domain(
        $data->{domain},
      );

      for my $name (@{ $data->{families} }) {
        my $family = $self->hub->node_family($name);

        $node->add_to_family($family);
      }
    }
  }
}

sub populate_hosts {
  my ($self) = @_;
  my $root = $self->root;
  for my $file (File::Find::Rule->file->in("$root/hosts")) {
    for my $data (YAML::XS::LoadFile($file)) {
      my $location = $self->hub->location($data->{location});

      my $interfaces;
      if (ref $data->{ip}) {
        $interfaces = [
          map {;
            [
            $data->{ip}{$_} => $self->hub->location($_) ] 
          } keys %{ $data->{ip}}
        ];
      } else {
        $interfaces = [ [ $data->{ip} => $self->hub->location('world') ] ];
      }

      my $node = $self->hub->host(
        $data->{domain},
        $data->{hostname},
        {
          interfaces => $interfaces,
          location   => $data->{location},
          aliases    => $data->{aliases} || [],
        },
      );

      for my $name (@{ $data->{families} }) {
        my $family = $self->hub->node_family($name);

        $node->add_to_family($family);
      }
    }
  }
}

1;

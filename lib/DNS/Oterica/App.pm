package DNS::Oterica::App;
# ABSTRACT: the code behind `dnsoterica`
use Moose;
use DNS::Oterica::Hub;
use File::Find::Rule;
use YAML::XS ();

has hub => (
  is  => 'ro',
  isa => 'DNS::Oterica::Hub',
  handles => [qw/
    add_location
    domain
    location
    host
    nodes
    node_family
    node_families
  /],
  default => sub { DNS::Oterica::Hub->new },
);

sub populate_domains {
  my ($self, $root) = @_;
  for my $file (File::Find::Rule->file->in("$root/domains")) {
    for my $data (YAML::XS::LoadFile($file)) {
      my $node = $self->domain(
        $data->{domain},
      );

      for my $name (@{ $data->{families} }) {
        my $family = $self->node_family($name);

        $node->add_to_family($family);
      }
    }
  }
}

sub populate_hosts {
  my ($self, $root) = @_;
  for my $file (File::Find::Rule->file->in("$root/hosts")) {
    for my $data (YAML::XS::LoadFile($file)) {
      my $location = $self->location($data->{location});

      my $interfaces;
      if (ref $data->{ip}) {
        $interfaces = [
          map {;
            [
            $data->{ip}{$_} => $self->location($_) ] 
          } keys %{ $data->{ip}}
        ];
      } else {
        $interfaces = [ [ $data->{ip} => $self->location('world') ] ];
      }

      my $node = $self->host(
        $data->{domain},
        $data->{hostname},
        {
          interfaces => $interfaces,
          location   => $data->{location},
          aliases    => $data->{aliases} || [],
        },
      );

      for my $name (@{ $data->{families} }) {
        my $family = $self->node_family($name);

        $node->add_to_family($family);
      }
    }
  }
}

1;

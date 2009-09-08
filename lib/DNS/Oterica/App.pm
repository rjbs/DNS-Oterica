package DNS::Oterica::App;
# ABSTRACT: the code behind `dnsoterica`
use Moose;
use DNS::Oterica::Hub;
use File::Find::Rule;
use YAML::XS ();

has hub => (
  is  => 'ro',
  isa => 'DNS::Oterica::Hub',
  default => sub { DNS::Oterica::Hub->new },
);

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

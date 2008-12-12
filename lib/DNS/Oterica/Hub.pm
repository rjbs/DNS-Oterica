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

has nodes => (
  is  => 'ro',
  isa => 'ArrayRef[DNS::Oterica::Node]',
  auto_deref => 1,
  init_arg   => undef,
  default    => sub { [] },
);

__PACKAGE__->meta->make_immutable;
no Moose;
1;

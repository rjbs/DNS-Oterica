package DNS::Oterica::NodeFamily;
# ABSTRACT: a group of hosts that share common functions
use Moose;

=attr nodes

This is an arrayref of the node objects that are in this family.

=cut

has nodes => (
  isa => 'ArrayRef',
  init_arg   => undef,
  default    => sub { [] },
  traits   => [ 'Array' ],
  handles  => {
    nodes      => 'elements',
    _push_node => 'push',
  },
);

=method add_node

  $family->add_node($node);

This adds the given node to the family.

=cut

# XXX: do not allow dupes -- rjbs, 2009-09-11
sub add_node {
  my ($self, $node) = @_;

  $self->_push_node( $node );
}

=method as_data_lines

This method returns a list of lines of configuration.  By default it only
generates begin and end marking comments.  This method is meant to be augmented
by subclasses.

=cut

sub as_data_lines {
  my ($self) = @_;

  my @lines;

  push @lines, $self->rec->comment("begin family " . $self->name);
  push @lines, $_ for inner();
  push @lines, $self->rec->comment("end family " . $self->name);

  return @lines;
}

with 'DNS::Oterica::Role::HasHub';

__PACKAGE__->meta->make_immutable;
no Moose;
1;

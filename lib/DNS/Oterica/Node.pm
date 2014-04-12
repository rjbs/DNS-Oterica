package DNS::Oterica::Node;
# ABSTRACT: DNSO node. belongs to families. 

use Moose;

use DNS::Oterica::Role::RecordMaker;

=head1 OVERVIEW

A node is any part of a network, either a domain or a node.  It is a member of
zero or more families.

Like other DNS::Oterica objects, they should be created through the hub.

=attr domain

This is a string representing the domain's domain name, for example
F<example.com>.

=cut

has domain   => (is => 'ro', isa => 'Str', required => 1);

=attr families

This is an arrayref of the families in which the node has been placed.

=cut

has families => (is => 'ro', isa => 'ArrayRef', default => sub { [] });

=method add_to_family

  $node->add_to_family($family);

This method adds the node to the given family, which may be given either as an
object or as a name.

If the node is already in the family, nothing happens.

=cut

sub add_to_family {
  my ($self, $family) = @_;
  $family = $self->hub->node_family($family) unless ref $family;
  return if $self->in_node_family($family);
  $family->add_node($self);
  push @{ $self->families }, $family;
}

=method in_node_family

  if ($node->in_node_family($family)) { ... }

This method returns true if the node is a member of the named (or passed)
family and false otherwise.

=cut

sub in_node_family {
  my ($self, $family) = @_;
  $family = $self->hub->node_family($family) unless ref $family;

  for my $node_family (@{ $self->families }) {
    return 1 if $family == $node_family;
  }

  return;
}

=method as_data_lines

This method returns a list of lines of configuration output.

By default, it returns nothing.

=cut

sub as_data_lines {
  confess 'do not call ->as_data_lines in non-list context' unless wantarray;
  return;
}

with 'DNS::Oterica::Role::HasHub';

__PACKAGE__->meta->make_immutable;
no Moose;
1;

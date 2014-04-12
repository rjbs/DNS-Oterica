package DNS::Oterica::Role::HasHub;
# ABSTRACT: any part of the dnso system that has a reference to the hub

use Moose::Role;

use namespace::autoclean;

has hub => (
  is   => 'ro',
  isa  => 'DNS::Oterica::Hub',
  weak_ref => 1,
  required => 1,
  # handles  => 'DNS::Oterica::Role::RecordMaker',
  handles  => [ qw(rec) ],
);

1;

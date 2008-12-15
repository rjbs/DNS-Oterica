package DNS::Oterica::Node::Domain;
use Moose;
extends 'DNS::Oterica::Node';

with 'DNS::Oterica::Role::RecordMaker';

sub fqdn {
  $_[0]->domain;
}

sub as_data_lines {
  return;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

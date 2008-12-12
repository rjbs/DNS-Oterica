package DNS::Oterica::NodeRole::Archiver;
use Moose;
extends 'DNS::Oterica::NodeRole';

sub name { 'com.listbox.archiver' }

__PACKAGE__->meta->make_immutable;
no Moose;
1;

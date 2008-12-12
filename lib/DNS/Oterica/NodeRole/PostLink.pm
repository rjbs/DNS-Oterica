package DNS::Oterica::NodeRole::PostLink;
use Moose;
extends 'DNS::Oterica::NodeRole';

sub name { 'com.listbox.postlink' }

__PACKAGE__->meta->make_immutable;
no Moose;
1;

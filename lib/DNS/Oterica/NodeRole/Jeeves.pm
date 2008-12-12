package DNS::Oterica::NodeRole::Jeeves;
use Moose;
extends 'DNS::Oterica::NodeRole';

sub name { 'com.listbox.jeeves' }

__PACKAGE__->meta->make_immutable;
no Moose;
1;

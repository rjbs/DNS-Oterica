package DNS::Oterica::Role::RecordMaker;
use Moose::Role;

use DNS::Oterica::Util::RecordMaker;

sub rec { 'DNS::Oterica::Util::RecordMaker' }

no Moose::Role;
1

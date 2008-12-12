use strict;
use warnings;
package DNS::Oterica::Util::RecordMaker;

# =fqdn:ip:ttl:timestamp:lo
sub a_and_ptr {
  my ($self, $rec) = @_;
  return sprintf "=%s:%s:%s:%s:%s\n",
    $rec->{name},
    $rec->{ip},
    $rec->{ttl} || 3600,
    $^T,
    $rec->{loc} || '',
  ;
}

1;

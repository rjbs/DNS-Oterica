use strict;
use warnings;
package DNS::Oterica::Util::RecordMaker;

sub _generic {
  my ($self, $op, $rec) = @_;
  return sprintf "%s%s:%s:%s:%s:%s\n",
    $op,
    $rec->{name},
    $rec->{ip},
    $rec->{ttl} || 3600,
    $^T,
    $rec->{loc} || '',
  ;
}

# =fqdn:ip:ttl:timestamp:lo
sub a_and_ptr {
  my ($self, $rec) = @_;
  $self->_generic(q{=}, $rec);
}

# +fqdn:ip:ttl:timestamp:lo
sub a {
  my ($self, $rec) = @_;
  $self->_generic(q{+}, $rec);
}


1;

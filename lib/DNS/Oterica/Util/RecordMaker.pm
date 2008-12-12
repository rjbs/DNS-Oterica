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

# @fqdn:ip:x:dist:ttl:timestamp:lo
sub mx {
  my ($self, $rec) = @_;
  return sprintf "@%s:%s:%s:%s:%s\n",
    $rec->{name},
    $rec->{ip},
    $rec->{mx},
    $rec->{dist} || 10,
    $rec->{ttl} || 3600,
    $^T,
    $rec->{loc} || '',
  ;
}


1;

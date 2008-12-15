use strict;
use warnings;
package DNS::Oterica::Util::RecordMaker;

sub _default_ttl { 3600 }

sub __ip_locode_pairs {
  my ($self, $rec) = @_;

  if ($rec->{node} and $rec->{ip} || $rec->{loc}) {
    Carp::confess('provide either a node or an ip/loc, not both');
  }

  if (not $rec->{node} || $rec->{ip}) {
    Carp::confess('provide either a node or an ip/loc');
  }

  # This is what we'd do to emit one record per interface to implement a split
  # horizon in the tinydns data file.  This is probably not what we want to end
  # up doing.  -- rjbs, 2008-12-12
  # return map {; [ $_->[0] => $_->[1]->code ] } $rec->{node}->interfaces
  #   if $rec->{node};

  return
    map  {; [ $_->[0] => $_->[1]->code ] }
    grep { $_->[1]->name eq 'world' }
    $rec->{node}->interfaces
    if $rec->{node};

  return [ $rec->{ip}, $rec->{loc} || '' ];
}

sub _generic {
  my ($self, $op, $rec) = @_;

  my @lines;
  for my $if ($self->__ip_locode_pairs($rec)) {
    push @lines, sprintf "%s%s:%s:%s:%s:%s\n",
      $op,
      $rec->{name},
      $if->[0],
      $rec->{ttl} || $self->_default_ttl,
      $^T,
      $if->[1],
    ;
  }

  return @lines;
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

  my @lines;

  my $mx_name = defined $rec->{mx} ? $rec->{mx}
              : $rec->{node}       ? $rec->{node}->fqdn
              : Carp::confess('neither mx nor node given as mx for mx record');
  
  for my $if ($self->__ip_locode_pairs($rec)) {
    push @lines, sprintf "@%s:%s:%s:%s:%s:%s:%s\n",
      $rec->{name},
      $if->[0],
      $mx_name,
      $rec->{dist} || 10,
      $rec->{ttl} || $self->_default_ttl,
      $^T,
      $if->[1],
    ;
  }

  return @lines;
}

# .fqdn:ip:x:ttl:timestamp:lo
# This doesn't handle nodes, because I don't want to deal with ip-less records,
# which would cause __generic to barf.  This is just a hack for now.
# -- rjbs, 2008-12-15
sub domain {
  my ($self, $rec) = @_;

  my @lines;

  push @lines, sprintf ".%s:%s:%s:%s:%s:%s\n",
    $rec->{domain},
    $rec->{ip} || '',
    $rec->{ns},
    $rec->{ttl} || $self->_default_ttl,
    $^T,
    '',
  ;

  return @lines;
}

1;

use strict;
use warnings;
package DNS::Oterica::Util::RecordMaker;
# ABSTRACT: a tinydns recordmaker for DNSO.

=head1 NAME

DNS::Oterica::Util::RecordMaker -- tinydns recordmaker for DNS::Oterica

=head1 DESCRIPTION

This role provides logic for generating lines for the L<tinydns-data(8)>
program to consume. It expects to be called via the
L<DNS::Oterica::Role::RecordMaker> delegator.

=head1 METHODS

=over 4

=cut

sub _default_ttl { 3600 }

sub comment {
  my ($self, $comment) = @_;

  return "# $comment\n";
}

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

=item a_and_ptr

Generate an C<=> line, the bread and butter A and PTR record pair for a
hostname and IP.

=cut

# =fqdn:ip:ttl:timestamp:lo
sub a_and_ptr {
  my ($self, $rec) = @_;

  return (
    $self->_generic(q{+}, $rec),
    $self->ptr($rec),
  );
}

=item ptr

Generate an C<^> line, for the reverse DNS of an IP address.

=cut

# ^fqdn:ip:ttl:timestamp:lo
# can't use __generic here because it wants to look at interfaces, and we want
# the reverse of that
sub ptr {
  my ($self, $rec) = @_;

    my @lines;
    for my $if ($self->__ip_locode_pairs($rec)) {
      my $ip = $if->[0];
      my @bytes = reverse split /\./, $ip;
      splice @bytes, 1, 1, '0-24', $bytes[1];
      my $extended_arpa = join '.', @bytes, 'in-addr', 'arpa';
      push @lines, sprintf "^%s:%s:%s:%s:%s\n",
        $extended_arpa,
        $rec->{name},
        $rec->{ttl} || $self->_default_ttl,
        $^T,
        $if->[1];
    }
    return @lines;
}

# TODO find out why we generate Z and & records for our IPs and refactor this
# to not duplicate effort with &ptr and the like. problem is that &a calls &ptr
# so having the code there means it gets called for every time we generate a +
# record, totally not what we want. What we want is for this to be called once
# for every IP address, not every hostname.
sub soa_and_ns_for_ip {
  my ($self, $rec) = @_;

  my @lines;
  my %ns = $rec->{node}->hub->node_family('com.rightbox.ns')->ns_nodes;
  my $ip = $rec->{ip};
  my @bytes = reverse split /\./, $ip;
  my $arpa = join '.', @bytes, 'in-addr', 'arpa';
  push @lines, sprintf "Z%s:%s:%s::::::%s:%s:%s\n",
    $arpa,
    'ns3.rightbox.com',
    "hostmaster.icgroup.com",
    $self->_default_ttl,
    $^T,
    '', ;
  for my $ns (keys %ns) {
    push @lines, $self->domain({
      domain => $arpa,
      ip     => $ip,
      ns     => $ns,
    });
  }
  return @lines;
}

# +fqdn:ip:ttl:timestamp:lo
sub a {
  my ($self, $rec) = @_;
  my @lines = $self->_generic(q{+}, $rec);

  # if  $rec->{node}->hub->location($rec->{node}->location)->delegated) {
  #   push @lines, $self->ptr($rec);
  # }

  return @lines;
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

  push @lines, sprintf "&%s:%s:%s:%s:%s:%s\n",
    $rec->{domain},
    $rec->{ip} || '',
    $rec->{ns},
    $rec->{ttl} || $self->_default_ttl,
    $^T,
    '',
  ;

  return @lines;
}

sub soa_and_ns {
  my ($self, $rec) = @_;

  my @lines;

  push @lines, sprintf "Z%s:%s:%s::::::%s:%s:%s\n",
    $rec->{domain},
    $rec->{ns} || '',
    "hostmaster\@icgroup.com",
    $rec->{ttl} || $self->_default_ttl,
    $^T,
    '',
  ;

  return @lines;
}


# Cfqdn:p:ttl:timestamp:lo
sub cname {
  my ($self, $rec) = @_;

  my @lines;

  push @lines, sprintf "C%s:%s:%s:%s:%s\n",
    $rec->{cname},
    $rec->{domain} || '',
    $rec->{ttl} || $self->_default_ttl,
    $^T,
    '',
  ;

  return @lines;
}

1;

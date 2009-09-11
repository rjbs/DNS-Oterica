use strict;
use warnings;
package DNS::Oterica;

=head1 NAME

DNS::Oterica - build dns configuration more easily

=head1 WARNING

B<HIGHLY EXPERIMENTAL>

This code is really not stable yet.  We're using it, and we're going to feel
free to make incompatible changes to it whenever we want.  Eventually, that
might change and we will reach a much stabler release cycle.

This code has been released so that you can see what it does, use it
cautiously, and help guide it toward a stable feature set.

=head1 OVERVIEW

DNS::Oterica is a system for generating DNS server configuration based on
system definitions and role-based plugins.  You need to provide a few things:

=head2 domain definitions

Domains are groups of hosts.  You know, domains.  This is a DNS tool.  If you
don't know what a domain is, you're in the wrong place.

=head2 host definitions

A host is a box with one or more interfaces.  It is part of a domain, it has a
hostname and maybe some aliases.  It's a member of zero or more node groups.

=head2 node families

Nodes (both hosts and domains) can be parts of families.  Families are groups
of behavior that nodes perform.  A family object is instantiated for each
family, and once all nodes have been added to the DNS::Oterica hub, the family
can emit more configuration.

=head1 I WANT TO KNOW MORE

Please read L<DNS::Oterica::Tutorial|DNS::Oterica::Tutorial>, which may or may
not yet exist.

=cut

1;

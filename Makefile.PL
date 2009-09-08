use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'DNS-Oterica',
    AUTHOR              => 'Ricardo SIGNES <rjbs@cpan.org>',
    VERSION_FROM        => 'lib/DNS/Oterica.pm',
    ABSTRACT_FROM       => 'lib/DNS/Oterica.pm',
    PL_FILES            => {},
    EXE_FILES           => [ 'bin/dnsoterica' ],
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'DNS-Oterica-*' },
);

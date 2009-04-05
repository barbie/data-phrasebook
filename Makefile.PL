use ExtUtils::MakeMaker;
WriteMakefile(
    NAME            => 'Data::Phrasebook',
    VERSION_FROM    => 'lib/Data/Phrasebook.pm',
    PREREQ_PM       => {
        'Module::Pluggable' => '2.5',
        'Test::More'        => '0.47',
    },
    ($] >= 5.005 ?
        (ABSTRACT_FROM  => 'lib/Data/Phrasebook.pm',
         AUTHOR         => 'Barbie <barbie@cpan.org>') : ()),
);

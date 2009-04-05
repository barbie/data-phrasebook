use ExtUtils::MakeMaker;
WriteMakefile(
    NAME            => 'Data::Phrasebook',
    VERSION_FROM    => 'lib/Data/Phrasebook.pm',
    PREREQ_PM       => {
        'Module::Pluggable' => '2.7',
        'Test::More'        => '0.47',
    },
    NO_META         => 1,

    ($] >= 5.005 ?
        (ABSTRACT_FROM  => 'lib/Data/Phrasebook.pm',
         AUTHOR         => 'Barbie <barbie@cpan.org>') : ()),
);

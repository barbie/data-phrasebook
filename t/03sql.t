#!/usr/bin/perl -w
use strict;
use lib 't';
use vars qw( $class );
use BookDB;

use Test::More tests => 7;

# ------------------------------------------------------------------------

my ($mock1);

BEGIN {
    $class = 'Data::Phrasebook';
    use_ok $class;

	eval "use Test::MockObject";
	plan skip_all => "Test::MockObject required for testing" if $@;

	$mock1 = Test::MockObject->new();
	$mock1->fake_module( 'DBI::db', 
				'prepare' =>\&BookDB::prepare,
				'prepare_cached' =>\&BookDB::prepare_cached,
				'rebind' =>\&BookDB::rebind,
				'bind_param' =>\&BookDB::bind_param,
				'execute' =>\&BookDB::execute,
				'fetchrow_hashref' =>\&BookDB::fetchrow_hashref,
				'fetchall_arrayref' =>\&BookDB::fetchall_arrayref,
				'fetchrow_array' =>\&BookDB::fetchrow_array,
				'finish' =>\&BookDB::finish);
	$mock1->fake_new( 'DBI::db' );
	$mock1->mock( 'prepare', \&BookDB::prepare );
	$mock1->mock( 'prepare_cached', \&BookDB::prepare_cached );
	$mock1->mock( 'rebind', \&BookDB::rebind );
	$mock1->mock( 'bind_param', \&BookDB::bind_param );
	$mock1->mock( 'execute', \&BookDB::execute );
	$mock1->mock( 'fetchrow_hashref', \&BookDB::fetchrow_hashref );
	$mock1->mock( 'fetchall_arrayref', \&BookDB::fetchall_arrayref );
	$mock1->mock( 'fetchrow_array', \&BookDB::fetchrow_array );
	$mock1->mock( 'finish', \&BookDB::finish );
}

use DBI::db;

my $file = 't/03phrases.txt';

# ------------------------------------------------------------------------

{
    my $dbh = BookDB->new();

    my $obj = $class->new(
        class => 'SQL',
        file => $file,
        dbh => $dbh,
    );
    my $author = 'Lance Parkin';
    my $q = $obj->query( 'find_author', {
            author => \$author,
        });
    isa_ok( $q => 'Data::Phrasebook::SQL::Query' );

    $q->prepare();

    {
        my $count = 0;
        $q->execute();
        while ( my $row = $q->fetchrow_hashref )
        {
            $count++ if $row->{author} eq $author;
        }
        is( $count => 7, "7 Parkins" );
        $q->finish();
    }

    {
        my $count = 0;
        $author = 'Paul Magrs';
        $q->execute();
        while ( my $row = $q->fetchrow_hashref )
        {
            $count++ if $row->{author} eq $author;
        }
        is( $count => 3, "3 Magrs" );
        $q->finish();
    }

    {
        my $count = 0;
        $q->execute( author => 'Lawrence Miles' );
        while ( my $row = $q->fetchrow_hashref )
        {
            $count++ if $row->{author} eq 'Lawrence Miles';
        }
        is( $count => 7, "7 Miles" );
        $q->finish();
    }
}

{
    my $dbh = BookDB->new();

    my $obj = $class->new(
        class => 'SQL',
        file => $file,
        dbh => $dbh,
    );
    my $author = 'Lance Parkin';
    my $q = $obj->query( 'find_author' );
    isa_ok( $q => 'Data::Phrasebook::SQL::Query' );

    {
        my $count = 0;
        $q->execute( author => 'Lawrence Miles' );
        while ( my $row = $q->fetchrow_hashref )
        {
            $count++ if $row->{author} eq 'Lawrence Miles';
        }
        is( $count => 7, "7 more Miles" );
    }
}

#!/usr/bin/perl -w
use strict;
use lib 't';
use vars qw( $class );
use BookDB;

use Test::More tests => 5;

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

my $file = 't/02phrases.txt';

# ------------------------------------------------------------------------

{
    my $dbh = BookDB->new();

    my $obj = $class->new(
        class => 'SQL',
        file => $file,
        dbh => $dbh,
    );

    my ($count) = $obj
        ->query( 'count_author', {
                author => 'Lawrence Miles'
            } )
        ->fetchrow_array;

    is( $count => 7, "Quick Miles" );
}

{
    my $dbh = BookDB->new();

    my $obj = $class->new(
        class => 'SQL',
        file => $file,
        dbh => $dbh,
    );

    my $author = 'Lawrence Miles';
    my $q = $obj->query( 'find_author' );
    isa_ok( $q => 'Data::Phrasebook::SQL::Query' );

    # Slow
    {
        my $count = 0;
        $q->execute( author => $author );
        while ( my $row = $q->fetchrow_hashref )
        {
            $count++ if $row->{author} eq $author;
        }
        is( $count => 7, "row by row Miles" );
        $q->finish;
    }

    # fetchall_arrayref
    {
        my $count = 0;
        $q->execute( author => $author );
        my $r = $q->fetchall_arrayref;
        is ( scalar @$r => 7, "fetchall Miles" );
        $q->finish;
    }
}

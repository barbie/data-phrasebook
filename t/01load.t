#!/usr/bin/perl -w
use strict;
use lib 't';
use vars qw( $class $subclass );

use Test::More tests => 20;

# ------------------------------------------------------------------------

BEGIN {
    $class = 'Data::Phrasebook';
    use_ok $class;

    $subclass = 'MyPhrasebook';
    use_ok $subclass;
}

my $file = 't/01phrases.txt';
my $file2 = 't/01phrases2.txt';

# ------------------------------------------------------------------------

{
    my $obj = $class->new;
    isa_ok( $obj => "${class}::Plain", 'Class new' );
    $obj->file( $file );
    is( $obj->file() => $file , 'Set/get file works');
}

{
    my $obj = $subclass->new;
    isa_ok( $obj => "${class}::Plain", 'Subclass new' );
    $obj->file( $file );
    is( $obj->file() => $file , 'Set/get file works');
}

{
    my $obj = $subclass->new( class => 'MyClass' );
    isa_ok( $obj => "MyClass", 'Subbed subclass new' );
    $obj->file( $file );
    is( $obj->file() => $file , 'Set/get file works');
}

{
	my $obj;
    eval { $obj = $subclass->new( class => 'BadClass' ); };
    is( $obj, undef, 'Nonexistent subbed subclass new' );
}

{
    my $obj = $class->new( file => $file );
    isa_ok( $obj => "${class}::Plain", 'New with file' );
    is( $obj->file() => $file , 'Get file works');

    {
        $obj->delimiters( qr{ \[% \s+ (\w+) \s+ %\] }x );

        my $str = $obj->fetch( 'foo', {
                my => "Iain's",
                place => 'locale',
            });

        is ($str, "Welcome to Iain's world. It is a nice locale.",
            'Fetch matches' );
    }

    {
        $obj->delimiters( qr{ :(\w+) }x );

        my $str = $obj->fetch( 'bar', {
                my => "Bob's",
                place => 'whatever',
            });

        is ($str, "Welcome to Bob's world. It is a nice whatever.",
            'Fetch matches' );
    }
}

{
    my $obj = $class->new;
    $obj->file( $file );
    is( $obj->file() => $file , 'Set/get file works');
    my $str = $obj->fetch( 'baz' );
    is($str, 'This is File 1');

    $obj->file( $file2 );
    is( $obj->file() => $file2 , 'Set/get file works');
    $str = $obj->fetch( 'baz' );
    is($str, 'This is File 2');

    $obj->file( $file );
    eval { $str = $obj->fetch( 'bar' ); };
    like($@, qr/No value/);
    eval { $str = $obj->fetch( 'notfound' ); };
    like($@, qr/No mapping/);
}

{
    eval { my $obj = $class->new(class  => 'Plain', loader => 'Bogus' ); $obj->fetch( 'bar' ); };
    like($@, qr/no loader available of that name/);
}
#!/usr/bin/perl -w
use strict;
use lib 't';
use vars qw( $class );

use Test::More tests => 11;

# ------------------------------------------------------------------------

BEGIN {
    $class = 'Data::Phrasebook';
    use_ok $class;
}

my $file = 't/01phrases.txt';
my $file2 = 't/01phrases2.txt';

# ------------------------------------------------------------------------

{
    my $obj = $class->new;
    isa_ok( $obj => "${class}::Plain", 'Bare new' );
    $obj->file( $file );
    is( $obj->file() => $file , 'Set/get file works');
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
}


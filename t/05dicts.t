#!/usr/bin/perl -w
use strict;
use lib 't';
use vars qw( $class );

use Test::More tests => 4;
use Data::Phrasebook;

my $file = 't/02dict.ini';

# load up the default dict
my $book = Data::Phrasebook->new(class  => 'Plain',
                                 loader => 'Text',
                                 file   => 't/phrases');

my @dicts = $book->dicts();
is(scalar(@dicts),2);
is($dicts[0],'english.txt');

$book->dict('english.txt');
is($book->fetch('foo'), "this is English");

# now switch to the second one
$book->dict('german.txt');
is($book->fetch('foo'), "diese ist Deutsche");

package Data::Phrasebook::Loader::Text;
use strict;
use warnings FATAL => 'all';
use base qw( Data::Phrasebook::Loader::Base Data::Phrasebook::Debug );
use Carp qw( croak );

our $VERSION = '0.23';

=head1 NAME

Data::Phrasebook::Loader::Text - Absract your phrases with plain text files.

=head1 SYNOPSIS

    use Data::Phrasebook;

    my $q = Data::Phrasebook->new(
        class  => 'Fnerk',
        loader => 'Text',
        file   => 'phrases.txt',
    );

    # use default delimiters (:variable)
    my $phrase = $q->fetch($keyword,{variable => 'substitute'});

    # use Template Toolkit style delimiters
    $q->delimiters( qr{ \[% \s* (\w+) \s* %\] }x );
    my $phrase = $q->fetch($keyword,{variable => 'substitute'});

=head1 ABSTRACT

This module provides a loader class for phrasebook implementations using 
plain text files.

=head1 DESCRIPTION

This loader plugin implements phrasebook patterns using plain text files. 

Phrases can be contained within one or more dictionaries, with each phrase 
accessible via a unique key. Phrases may contain placeholders, please see 
L<Data::Phrasebook> for an explanation of how to use these. Groups of phrases
are kept in a dictionary. In this implementation a single file is one
complete dictionary.

An example plain text file:

  foo=Welcome to :my world. It is a nice :place.

Within the phrase text placeholders can be used, which are then replaced with 
the appropriate values once the get() method is called. The default style of
placeholders can be altered using the delimiters() method.

=head1 INHERITANCE

L<Data::Phrasebook::Loader::Text> inherits from the base class
L<Data::Phrasebook::Loader::Base>.
See that module for other available methods and documentation.

=head1 METHODS

=head2 load

Given a C<file>, load it. C<file> must contain a valid phrase map.

   my $file = 'english.txt';
   $loader->load( $file );

This method is used internally by L<Data::Phrasebook::Generic>'s
C<data> method, to initialise the data store.

To utilise the dictionary framework for a Plain Text phrasebook, the idea is
to use a directory of files, where the directory is passed via the C<file>
argument and the dictionary, the specific name of the file, is passed via
the C<dictionary> argument.

   my $file = '/tmp/phrasebooks';
   my $dictionary = 'english.txt';
   $loader->load( $file, $dictionary );

=cut

my %phrasebook;

sub load {
    my ($class, $file, $dict) = @_;
    $class->store(3,"->load IN");

    $file ||= $class->{parent}->file;
    $dict ||= $class->{parent}->dict;
    croak "No file given as argument!" unless defined $file;

    $file = "$file/$dict"	if(-d $file && defined $dict);
    croak "File [$file] not accessible!" unless -f $file && -r $file;

    %phrasebook = ();   # ignore previous dictionary
    open BOOK, $file    or return undef;
    while(<BOOK>) {
        my ($name,$value) = (/(.*?)=(.*)/);
        $phrasebook{$name} = $value if($name);  # value can be blank
    }
    close BOOK;
}

=head2 get

Returns the phrase stored in the phrasebook, for a given keyword.

   my $value = $loader->get( $key );

=cut

sub get {
    my ($class, $key) = @_;
    if($class->debug) {
        $class->store(3,"->get IN");
        $class->store(4,"->get key=[$key]");
        $class->store(4,"->get phrase=[".($phrasebook{$key} || 'undef')."]");
    }
    return $phrasebook{$key};
}

=head2 dicts

Having instantiated the C<Data::Phrasebook> object class, and using the C<file>
attribute as a directory path, the object can return a list of the current
dictionaries available as:

  my $pb = Data::Phrasebook->new(
  	loader => 'Text',
	file   => '/tmp/phrasebooks',
  );

  my @dicts = $pb->dicts;

or

  my @dicts = $pb->dicts( $path );

=cut

sub dicts {
    my ($self,$path) = @_;
    $path ||= $self->{parent}->file;
    return ()	unless(-d $path && -r $path);

    my @files = map { s/$path.//;$_ } grep {/^[^\.]+/} glob("$path/*");
    return @files;
}

=head2 keywords

Having instantiated the C<Data::Phrasebook> object class, using the C<file>
and C<dict> attributes as required, the object can return a list of the 
current keywords available as:

  my $pb = Data::Phrasebook->new(
  	loader => 'Text',
	file   => '/tmp/phrasebooks',
	dict   => 'TEST',
  );

  my @keywords = $pb->keywords;

Note the list returned will be a combination of the default and any named
dictionary.

  my @keywords = $pb->keywords( $dict );

Note that $dict can be the full path or the file name for the current phrase
directory.

=cut

sub keywords {
    return keys %phrasebook if(@_ == 1);

    my ($self,$file,$dict) = @_;
    $file ||= $self->{parent}->file;
    $dict ||= $self->{parent}->dict;
    croak "No file given as argument!" unless defined $file;

    $file = "$file/$dict"	if(-d $file && defined $dict);
    croak "File [$file] not accessible!" unless -f $file && -r $file;

    my @keywords;
    open BOOK, $file    or return undef;
    while(<BOOK>) {
        push @keywords, $1   if(/(.*?)=/ && $1);
    }
    close BOOK;

    return @keywords;
}

1;

__END__

=head1 SEE ALSO

L<Data::Phrasebook>.

=head1 SUPPORT

Please see the README file.

=head1 AUTHOR

  Barbie, <barbie@cpan.org>
  for Miss Barbell Productions <http://www.missbarbell.co.uk>.

=head1 LICENCE AND COPYRIGHT

  Copyright (C) 2004-2005 Barbie for Miss Barbell Productions.

  This library is free software; you can redistribute it and/or modify
  it under the same terms as Perl itself.

The full text of the licences can be found in the F<Artistic> and
F<COPYING> files included with this module, or in L<perlartistic> and
L<perlgpl> in Perl 5.8.1 or later.

=cut
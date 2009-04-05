package Data::Phrasebook::Loader::Text;
use strict;
use warnings FATAL => 'all';
use base qw( Data::Phrasebook::Loader::Base Data::Phrasebook::Debug );
use Carp qw( croak );

our $VERSION = '0.03';

=head1 NAME

Data::Phrasebook::Loader::Text - Absract your phrases with plain text files.

=head1 SYNOPSIS

    use Data::Phrasebook;

    my $q = Data::Phrasebook->new(
        class  => 'Fnerk',
        loader => 'Text',
        file   => 'phrases.txt',
    );

   $q->delimiters( qr{ \[% \s* (\w+) \s* %\] }x );
	my $phrase = $q->fetch($keyword);

=head1 ABSTRACT

This module provides a loader class for phrasebook implementations using 
plain text files.

=head1 DESCRIPTION

This class loader implements phrasebook patterns using plain text files. 

Phrases can be contained within one or more dictionaries, with each phrase 
accessible via a unique key. Phrases may contain placeholders, please see 
L<Data::Phrasebook> for an explanation of how to use these. Groups of phrases
are kept in a dictionary. In this implementation a single file is one
complete dictionary.

An example plain text file:

  foo=Welcome to [% my %] world. It is a nice [% place %].

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

   $loader->load( $file );

This method is used internally by L<Data::Phrasebook::Generic>'s
C<data> method, to initialise the data store.

=cut

my %phrasebook;

sub load {
    my ($class, $file) = @_;
	$class->store(3,"->load IN");
    croak "No file given as argument!" unless defined $file;

	open BOOK, $file	or return undef;
	while(<BOOK>) {
		my ($name,$value) = (/(.*?)=(.*)/);
		$phrasebook{$name} = $value	if($name);	# value can be blank
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

1;

__END__

=head1 SEE ALSO

L<Data::Phrasebook>

=head1 AUTHOR

Barbie, C< <<barbie@cpan.org>> >
for Miss Barbell Productions, L<http://www.missbarbell.co.uk>

Birmingham Perl Mongers, L<http://birmingham.pm.org/>

=head1 COPYRIGHT AND LICENSE

  Copyright (C) 2004-2005 Barbie for Miss Barbell Productions
  All Rights Reserved.

  This module is free software; you can redistribute it and/or 
  modify it under the same terms as Perl itself.

  The full text of the licences can be found in the F<Artistic> and
  F<COPYING> files included with this module, or in L<perlartistic> and
  L<perlgpl> in Perl 5.8.1 or later.

=cut

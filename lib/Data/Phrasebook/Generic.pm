package Data::Phrasebook::Generic;
use strict;
use warnings FATAL => 'all';
use Data::Phrasebook::Loader;
use base qw( Data::Phrasebook::Debug );
use Carp qw( croak );

our $VERSION = '0.18';

=head1 NAME

Data::Phrasebook::Generic - Base class for Phrasebook Models

=head1 SYNOPSIS

    use Data::Phrasebook;

    my $q = Data::Phrasebook->new(
        class  => 'Fnerk',
        loader => 'XML',
        file   => 'phrases.xml',
        dict   => 'English',
    );

=head1 DESCRIPTION

This module provides a base class for phrasebook implementations.

=head1 CONSTRUCTOR

=head2 new

C<new> takes an optional hash of arguments. Each value in the hash
is given as an argument to a method of the same name as the key.

This constructor should B<never> need to be called directly
Phrasebook creation should go through the L<Data::Phrasebook> factory.

Subclasses who wish to override behaviour should actually override
C<init> (see source for details).

All, or at least I<most>, phrasebook implementations should inherit from
B<this> class.

=cut

sub new {
    my $class = shift;
	my %hash = @_;
	$class->store(3,"$class->new IN");
	my $atts = \%hash;
	$class->store(4,"$class->new args=[".$class->dumper($atts)."]");
	bless $atts, $class;
	return $atts;
}

=head1 METHODS

=head2 loader

Set, or get, the loader class. Uses a default if none have been
specified. See L<Data::Phrasebook::Loader>.

=head2 file

A description of a file that is passed to the loader. In most cases,
this is a file. A loader that gets its data from a database could
conceivably have this as a hash like thus:

   $q->file( {
       dsn => "dbi:SQLite:dbname=bookdb",
       table => 'phrases',
   } );

That is, which loader you use determines what your C<file> looks like.

The default loader takes just an ordinary filename.

=head2 loaded

Accessor to determine whether the current dictionary has been loaded

=head2 dict

Accessor to store the dictionary to be used.

=cut

sub loader {
	my $self = shift;
	@_ ? $self->{loader} = shift : $self->{loader};
}
sub file {
	my $self = shift;
	@_ ? $self->{file} = shift : $self->{file};
}
sub loaded {
	my $self = shift;
	@_ ? $self->{loaded} = shift : $self->{loaded};
}
sub dict {
	my $self = shift;
	@_ ? $self->{dict} = shift : $self->{dict};
}

=head2 data

Loads the data source, if not already loaded, and returns the data block 
associated with the given key.

    my $data = $self->data($key);

This is typically only used internally by implementations, not the end user.

=cut

sub data
{
    my $self = shift;
	my $id = shift;
	$self->store(3,"->data IN");
	$self->store(4,"->data id=[$id]");
	return	unless($id);

    my $loader = $self->loaded;
	if(!defined $loader) {
		if($self->debug) {
			$self->store(4,"->data loader=[".($self->loader||'undef')."]");
			$self->store(4,"->data file=[".($self->file||'undef')."]");
			$self->store(4,"->data dict=[".($self->dict||'undef')."]");
		}
        $loader = Data::Phrasebook::Loader->new('class' => $self->loader);
        $loader->load( $self->file, $self->dict );
		$self->loaded($loader);
	}

    $self->{'loaded-data'}->{$id} ||= do { $loader->get( $id ) };
}

1;

__END__

=head1 SEE ALSO

L<Data::Phrasebook>, 
L<Data::Phrasebook::Loader>.

=head1 AUTHOR

Original author: Iain Campbell Truskett (16.07.1979 - 29.12.2003).

Maintainer: Barbie <barbie@cpan.org>.

=head1 LICENCE AND COPYRIGHT

  Copyright E<copy> Iain Truskett, 2003. All rights reserved.
  Copyright E<copy> Barbie, 2004-2005. All rights reserved.

  This library is free software; you can redistribute it and/or modify
  it under the same terms as Perl itself.

  The full text of the licences can be found in the F<Artistic> and
  F<COPYING> files included with this module, or in L<perlartistic> and
  L<perlgpl> in Perl 5.8.1 or later.

=cut

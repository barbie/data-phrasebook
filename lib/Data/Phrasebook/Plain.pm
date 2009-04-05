package Data::Phrasebook::Plain;
use strict;
use warnings FATAL => 'all';
use base qw( Data::Phrasebook::Generic Data::Phrasebook::Debug );
use Carp qw( croak );

our $VERSION = '0.18';

=head1 NAME

Data::Phrasebook::Plain - Simplistic phrasebooking.

=head1 SYNOPSIS

    use Data::Phrasebook;

    my $q = Data::Phrasebook->new(
        class  => 'Plain',
        loader => 'Text',
        file   => 'phrases.txt',
    );

    my $r = Data::Phrasebook->new( file => 'phrases.txt' );

   $q->delimiters( qr{ \[% \s* (\w+) \s* %\] }x );
	my $phrase = $q->fetch($keyword);

=head1 DESCRIPTION

This module is the fallback or default phrasebook class. It doesn't do much 
except act as a very simple templating facility.

=head1 METHODS

=head2 fetch

Retrieves the specified C<template> and substitutes any C<keywords> for 
C<values>.

Thus, given:

    hello=Hello [% where %]!

And code:

    my $text = $q->fetch( 'hello', {
        where => 'world'
    } );

Return value is:

    Hello world!

The delimiters are deliberately taken from L<Template> Toolkit.

=cut

sub fetch
{
    my $self = shift;
    my ($id, $args) = @_;
	$self->store(3,"->fetch IN");

	my $map = $self->data($id);
    croak "No mapping for `$id'" unless($map);
    my $delim_RE = $self->delimiters || qr{ \[% \s* (\w+) \s* %\] }x;
    croak "Mapping for `$id` not a string." if ref $map;

	if($self->debug) {
		$self->store(4,"->fetch delimiters=[$delim_RE]");
		$self->store(4,"->fetch args=[".$self->dumper($args)."]");
	}

    $map =~ s{$delim_RE}[
         die "Croak no value given for `$1'" unless defined $args->{$1};
         $args->{$1};
    ]egx;

    return $map;
}

=head2 delimiters

Returns or sets the current delimiters for tags.
Must be a regex with at least one capture group.

This example also shows the default regex.

   $q->delimiters( qr{ \[% \s* (\w+) \s* %\] }x );

=cut

sub delimiters {
	my $self = shift;
	@_ ? $self->{delimiters} = shift : $self->{delimiters};
}

1;

__END__

=head1 SEE ALSO

L<Data::Phrasebook>, 
L<Data::Phrasebook::Generic>

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

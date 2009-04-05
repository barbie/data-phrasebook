package Data::Phrasebook;
use strict;
use warnings FATAL => 'all';
use base qw( Data::Phrasebook::Debug );
use Carp qw( croak );

our $VERSION = '0.18';

=head1 NAME

Data::Phrasebook - Abstract your queries!

=head1 SYNOPSIS

    use Data::Phrasebook;

    my $q = Data::Phrasebook->new(
        class  => 'Plain',
        loader => 'Text',
        file   => 'phrases.txt',
    );

   $q->delimiters( qr{ \[% \s* (\w+) \s* %\] }x );
	my $phrase = $q->fetch($keyword);

=head1 DESCRIPTION

This is a factory class for accessing phrasebooks.

To explain what phrasebooks are it is worth reading Rani Pinchuk's
(author of L<Class::Phrasebook>) article of Perl.com:

L<http://www.perl.com/pub/a/2002/10/22/phrasebook.html>

Common uses of phrasebooks are in handling error codes, accessing databases
via SQL queries and written language phrases. Examples are the mime.types
file and the hosts file, both of which use a simple phrasebook design.

Unfortunately Class::Phrasebook is a complete work and not a true class
based framework. If you can't install XML libraries, you cannot use it.
This distribution is a collaboration between Iain Truskett and myself to
create an extendable and class based framework for implementing phrasebooks.

Note that if using an implementation that supports dictionaries, they cannot
be changed once the loader class is instantiated. This may change in the 
future.

=head1 DEDICATION

Much of the work original class framework is from Iain's original code. My 
code was alot simpler and was tied to using just an INI data source. Merging 
all the ideas and code together we came up with this distribution.

Unfortunately Iain died in December 2003, so he never got to see or play
with the final working version. I can only thank him for his thoughts and 
ideas in getting this distribution into a state worthy of release.

  Iain Campbell Truskett (16.07.1979 - 29.12.2003)

=head1 CONSTRUCTOR

=head2 new

The arguments to new depend upon the exact class you're creating.

The default class is C<Plain>.

The C<class> argument defines the class type you wish to utilise. Currently
there are C<Plain> and C<SQL> classes available. The C<class> argument
is treated like this, using C<Foobar> as the sample value:

=over 4

=item 1

If you've subclassed C<Data::Phrasebook>, for example as C<Dictionary>,
then C<Dictionary::Foobar> is tried.

=item 2

If that failed, C<Data::Phrasebook::Foobar> is tried.

=item 3

If B<that> failed, C<Foobar> is tried.

=item 4

If all the above failed, we croak.

=back

This should allow you some flexibility in what sort of classes
you use while not having you type too much.

For other parameters, see the specific class you wish to instantiate.
The class argument is removed from the arguments list and the C<new>
method of the specified class is called with the remaining arguments.

=cut

sub new
{
    my $class = shift;
    my %args = @_;

    my $debug = delete $args{debug} || 0;
	$class->debug($debug);

	$class->store(3,"$class->new IN");
	$class->store(4,"$class->new args=[".$class->dumper(\%args)."]");

	my $sub = delete $args{class} || 'Plain';
    if (eval "require ${class}::$sub") {
        $sub = $class."::$sub";
    } elsif (eval "require Data::Phrasebook::$sub") {
        $sub = "Data::Phrasebook::$sub";
    } elsif (eval "require $sub") {
        # it's a module by itself
    } else {
        croak "Could not find appropriate class for `$sub': [$@]";
    }

	$class->store(4,"$class->new sub=[$sub]");
    my $self = $sub->new( %args );
}

1;


__END__

=head1 SEE ALSO

	L<Data::Phrasebook::Plain>
	L<Data::Phrasebook::SQL>
	L<Data::Phrasebook::Debug>

	L<Data::Phrasebook::Loader>
	L<Data::Phrasebook::Loader::Text>
	
	L<Data::Phrasebook::Generic> may also prove informative.

=head1 SUPPORT

Please see the README file.

=head1 AUTHOR

Original author: Iain Campbell Truskett (16.07.1979 - 29.12.2003)

Maintainer: Barbie <barbie@cpan.org> since January 2004.

=head1 LICENCE AND COPYRIGHT

  Copyright E<copy> Iain Truskett, 2003. All rights reserved.
  Copyright E<copy> Barbie, 2004-2005. All rights reserved.

  This library is free software; you can redistribute it and/or modify
  it under the same terms as Perl itself.

  The full text of the licences can be found in the F<Artistic> and
  F<COPYING> files included with this module, or in L<perlartistic> and
  L<perlgpl> in Perl 5.8.1 or later.

=cut

package Data::Phrasebook::Loader::Base;
use strict;
use warnings;# FATAL => 'all';
#use base qw( Class::WhiteHole Data::Phrasebook::Debug );
use base qw( Data::Phrasebook::Debug );
use Carp qw( croak );

our $VERSION = '0.01';

=head1 NAME

Data::Phrasebook::Loader::Base - base loader class

=head1 SYNOPSIS

N/A

=head1 DESCRIPTION

C<Data::Phrasebook::Loader::Base> acts as a base class for phrasebook 
plugins.

=head1 INHERITABLE METHODS

=head2 new

C<new> merely creates a new instance. Nothing exciting.
Override the C<init> method to augment functionality, but
be sure to call this one.

=head2 load

C<load> is an abstract method here. You must define your own
in your subclass.

=head2 get

C<get> is an abstract method here. You must define your own
in your subclass.

=head1 CONSTRUCTOR

=head2 new

C<new> takes one optional named argument: the class. It returns a new
instance to the class. Any further arguments to C<new> are given to
the C<new> method of the appropriate class.

If no class is specified the default class of 'Text' is used.

    my $loader = Data::Phrasebook::Loader->new();

    my $xmlloader = Data::Phrasebook::Loader->new(
        class => 'XML',
    );

=cut

sub new {
    my $self = shift;
	my %hash = @_;
	$self->store(3,"$self->new IN");
	my $atts = \%hash;
	bless $atts, $self;
	return $atts;
}

sub load { return undef }
sub get  { return undef }

1;

__END__

=head1 SEE ALSO

L<Data::Phrasebook>,
L<Data::Phrasebook::Loader>.

=head1 AUTHOR

Barbie, C< <<barbie@cpan.org>> >
for Miss Barbell Productions, L<http://www.missbarbell.co.uk>

Birmingham Perl Mongers, L<http://birmingham.pm.org/>

=head1 COPYRIGHT AND LICENSE

  Copyright (C) 2005 Barbie for Miss Barbell Productions
  All Rights Reserved.

  This module is free software; you can redistribute it and/or 
  modify it under the same terms as Perl itself.

  The full text of the licences can be found in the F<Artistic> and
  F<COPYING> files included with this module, or in L<perlartistic> and
  L<perlgpl> in Perl 5.8.1 or later.

=cut

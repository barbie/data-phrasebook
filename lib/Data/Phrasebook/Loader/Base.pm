package Data::Phrasebook::Loader::Base;
use strict;
use warnings FATAL => 'all';
use base qw( Data::Phrasebook::Debug );
use Carp qw( croak );

our $VERSION = '0.21';

=head1 NAME

Data::Phrasebook::Loader::Base - Base loader plugin class.

=head1 SYNOPSIS

  $class->new( %attributes );

=head1 DESCRIPTION

C<Data::Phrasebook::Loader::Base> acts as a base class for phrasebook 
plugins.

=head1 INHERITABLE METHODS

=head2 new

C<new> merely creates a new instance. Nothing exciting.

=head2 load

C<load> is an abstract method here. You must define your own
in your subclass.

=head2 get

C<get> is an abstract method here. You must define your own
in your subclass.

=head1 CONSTRUCTOR

=head2 new

C<new> instantiates the plugin object, creating a blessed hash of any
attributes passed as arguments.

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

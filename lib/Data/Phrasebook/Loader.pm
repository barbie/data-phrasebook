package Data::Phrasebook::Loader;
use strict;
use warnings FATAL => 'all';
use base qw( Data::Phrasebook::Debug );
use Carp qw( croak );

use Module::Pluggable   search_path => ['Data::Phrasebook::Loader'];

our $VERSION = '0.26';

=head1 NAME

Data::Phrasebook::Loader - Plugin Loader module

=head1 SYNOPSIS

  my $loader = Data::Phrasebook::Loader->new( class => 'Text' );

=head1 DESCRIPTION

C<Data::Phrasebook::Loader> acts as an autoloader for phrasebook plugins.

=head1 CONSTRUCTOR

=head2 new

C<new> takes one optional named argument: the class. It returns a new
instance to the class. Any further arguments to C<new> are given to
the C<new> method of the appropriate class.

If no class is specified the default class of 'Text' is used.

  my $loader = Data::Phrasebook::Loader->new();

  OR

  my $loader = Data::Phrasebook::Loader->new( class => 'Text' );

=cut

my $DEFAULT_CLASS = 'Text';

sub new
{
    my $self  = shift;
    my %args  = @_;
    my $class = delete $args{class} || $DEFAULT_CLASS;

    $self->store(3,"$self->new IN");
    $self->store(4,"$self->new class=[$class]");

    # in the event we have been subclassed
    $self->search_path( add => "$self" );

    my $plugin;
    my @plugins = $self->plugins();
    for(@plugins) {
        $plugin = $_    if($_ =~ /\b$class$/);
    }

    croak("no loader available of that name\n") unless($plugin);
    eval "CORE::require $plugin";
    croak "Couldn't require $plugin : $@" if $@;
    $self->store(4,"$self->new plugin=[$plugin]");
    return $plugin->new( %args );
}

1;

__END__

=head1 SEE ALSO

L<Data::Phrasebook>.

=head2 Known implementations

L<Data::Phrasebook::Loader::Text>,
L<Data::Phrasebook::Loader::YAML>,
L<Data::Phrasebook::Loader::Ini>,
L<Data::Phrasebook::Loader::XML>,
L<Data::Phrasebook::Loader::DBI>.

=head1 SUPPORT

Please see the README file.

=head1 AUTHOR

Original author: Iain Campbell Truskett (16.07.1979 - 29.12.2003)

Maintainer: Barbie <barbie@cpan.org> since January 2004.

=head1 LICENCE AND COPYRIGHT

  Copyright (C) Iain Truskett, 2003. All rights reserved.
  Copyright (C) Barbie, 2004-2005. All rights reserved.

  This library is free software; you can redistribute it and/or modify
  it under the same terms as Perl itself.

The full text of the licences can be found in the F<Artistic> and
F<COPYING> files included with this module, or in L<perlartistic> and
L<perlgpl> in Perl 5.8.1 or later.

=cut

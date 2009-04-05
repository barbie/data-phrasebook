package Data::Phrasebook::SQL;
use strict;
use warnings FATAL => 'all';
use base qw( Data::Phrasebook::Generic Data::Phrasebook::Debug );
use Carp qw( croak );

use Data::Phrasebook::SQL::Query;

our $VERSION = '0.22';

=head1 NAME

Data::Phrasebook::SQL - The SQL/DBI Phrasebook Model.

=head1 SYNOPSIS

    use Data::Phrasebook;
    use DBI;

    my $dbh = DBI->connect(...);

    my $book = Data::Phrasebook->new(
        class => 'SQL',
        dbh   => $dbh,
        file  => 'queries.txt',
    );
    my $q = $book->query( 'find_author', {
            author => "Lance Parkin"
        });
    while ( my $row = $q->fetchrow_hashref ) {
        print "He wrote $row->{title}\n";
    }
    $q->finish;

F<queries.txt>:

    find_author=select title,author from books where author = :author

=head1 DESCRIPTION

In order to make use of features like placeholders in DBI in conjunction
with phrasebooks, it's helpful to have a phrasebook be somewhat more aware
of how DBI operates. Thus, you get C<Data::Phrasebook::SQL>.

C<Data::Phrasebook::SQL> has knowledge of how DBI works and creates and
executes your queries appropriately.

=head1 CONSTRUCTOR

=head2 new

Not to be accessed directly, but via the parent L<Data::Phrasebook>, by 
specifying the class as SQL.

Additional arguments to those described in L<Data::Phrasebook::Generic> are:

=over 4

=item *

C<dbh> - a DBI database handle.

=back

=head1 METHODS

=head2 dbh

Set, or get, the current DBI handle.

=cut

sub dbh {
    my $self = shift;
    @_ ? $self->{dbh} = shift : $self->{dbh};
}

=head2 query

Constructs a L<Data::Phrasebook::SQL::Query> object from a template.
Takes two arguments, the first being a name for the query. This is
then looked for in the C<file> that was given. The second argument 
is an optional hashref of key to value mappings.

If phrasebook has a YAML source looking much like the following:

    ---
    find_author:
        sql: select class,title,author from books where author = :author

You could write:

    my $q = $book->query( 'find_author' );

    OR

    my $q = $book->query( 'find_author', {
        author => 'Lance Parkin'
    } );

    OR

    my $author = 'Lance Parkin';
    my $q = $book->query( 'find_author', {
        author => \$author,
    } );

If you ask for a template that is either not there or has no definition,
then an error will be thrown.

Consult L<Data::Phrasebook::SQL::Query> for what you can then do with your
returned object.

For reference: the hashref argument, if it is given, is given to the
query object's C<order_args> and then C<args> methods.
  
=cut

sub query {
    my $self = shift;
    my ($id, $args) = @_;
    $self->store(3,"->query IN");

    my $map = $self->data($id);
    croak "No mapping for `$id'" unless($map);
    my $sql = '';

    $self->store(4,"->query id=[$id]");
    $self->store(4,"->query map=[$map]");

    if(ref $map eq 'HASH') {
        croak "No SQL content for `$id'." unless exists $map->{sql}
            and defined $map->{sql};
        $sql = $map->{sql};
    } else {
        $sql = $map;    # we assume sql string only
    }

    my @order;

    my $delim_RE = $self->delimiters();
    $sql =~ s{$delim_RE}[
        push @order, $1;
        "?"
    ]egx;

    if($self->debug) {
        $self->store(4,"->query sql=[$sql]");
        $self->store(4,"->query order=[".join(",",@order)."]");
        $self->store(4,"->query args=[".$self->dumper($args)."]");
    }
    
    my $q = Data::Phrasebook::SQL::Query->new(
        sql => $sql,
        order => \@order,
        dbh => $self->dbh,
    );
    $q->args( $q->order_args( $args ) ) if $args;
    $q;
}


1;

__END__

=head1 SEE ALSO

L<Data::Phrasebook>,
L<Data::Phrasebook::Generic>,
L<Data::Phrasebook::SQL::Query>.

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

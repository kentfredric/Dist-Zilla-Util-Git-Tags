use strict;
use warnings;
use utf8;

package Dist::Zilla::Util::Git::Tags::Tag;
BEGIN {
  $Dist::Zilla::Util::Git::Tags::Tag::AUTHORITY = 'cpan:KENTNL';
}
{
  $Dist::Zilla::Util::Git::Tags::Tag::VERSION = '0.001001';
}

# ABSTRACT: A single tag object

use Moose;


has name => ( isa => Str    =>, required => 1, is => ro => );
has git  => ( isa => Object =>, required => 1, is => ro => );


sub sha1 {
  my ($self)  = @_;
  my (@sha1s) = $self->git->rev_parse( $self->name );
  if ( scalar @sha1s > 1 ) {
    require Carp;
    return Carp::confess(q[Fatal: rev-parse tagname returned multiple values]);
  }
  return shift @sha1s;
}


sub verify {
  my ( $self, ) = @_;
  return $self->git->tag( '-v', $self->name );
}


## no critic (ProhibitBuiltinHomonyms)

sub delete {
  my ( $self, ) = @_;
  return $self->git->tag( '-d', $self->name );
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Dist::Zilla::Util::Git::Tags::Tag - A single tag object

=head1 VERSION

version 0.001001

=head1 METHODS

=head2 C<sha1>

=head2 C<verify>

=head2 C<delete>

=head1 ATTRIBUTES

=head2 C<name>

=head2 C<git>

=head1 AUTHOR

Kent Fredric <kentfredric@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Kent Fredric <kentfredric@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

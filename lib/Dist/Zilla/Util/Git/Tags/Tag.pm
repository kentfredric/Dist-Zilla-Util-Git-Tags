use strict;
use warnings;
use utf8;

package Dist::Zilla::Util::Git::Tags::Tag;

# ABSTRACT: A single tag object

use Moose;

=attr C<name>

=attr C<git>

=cut

has name => ( isa => Str    =>, required => 1, is => ro => );
has git  => ( isa => Object =>, required => 1, is => ro => );

=method C<sha1>

=cut

sub sha1 {
  my ($self)  = @_;
  my (@sha1s) = $self->git->rev_parse( $self->name );
  if ( scalar @sha1s > 1 ) {
    require Carp;
    return Carp::confess(q[Fatal: rev-parse tagname returned multiple values]);
  }
  return shift @sha1s;
}

=method C<verify>

=cut

sub verify {
  my ( $self, ) = @_;
  return $self->git->tag( '-v', $self->name );
}

=method C<delete>

=cut

## no critic (ProhibitBuiltinHomonyms)

sub delete {
  my ( $self, ) = @_;
  return $self->git->tag( '-d', $self->name );
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;


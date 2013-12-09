use strict;
use warnings;
use utf8;

package Dist::Zilla::Util::Git::Tags::Tag;

# ABSTRACT: A single tag object

use Moose;

extends 'Dist::Zilla::Util::Git::Refs::Ref';

=attr C<name>

=attr C<git>

=cut

sub refname {
  my ($self) = @_;
  return 'refs/tags/' . $self->name;
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


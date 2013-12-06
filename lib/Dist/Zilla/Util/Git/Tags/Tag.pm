use strict;
use warnings;
use utf8;

package Dist::Zilla::Util::Git::Tags::Tag;

# ABSTRACT: A single tag object

use Moose;

=attr C<name>

=attr C<git>

=attr C<sha1>

=cut

has name => ( isa => Str    =>, required   => 1, is => ro => );
has git      => ( isa => Object =>, required   => 1, is => ro => );
has sha1     => ( isa => Str    =>, lazy_build => 1, is => ro => );

sub _build_sha1 {
  my ($self) = @_;
  $self->git->rev_parse( $self->tag_name );
}

=method C<verify>

=cut

sub verify {
  $self->git->tag( '-v', $self->tag_name );
}

=method C<delete>

=cut

sub delete {
  $self->git->tag( '-d', $self->tag_name );
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;


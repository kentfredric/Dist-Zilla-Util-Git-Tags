use strict;
use warnings;

package Dist::Zilla::Util::Git::Tags;
BEGIN {
  $Dist::Zilla::Util::Git::Tags::AUTHORITY = 'cpan:KENTNL';
}
{
  $Dist::Zilla::Util::Git::Tags::VERSION = '0.002000';
}

# ABSTRACT: Extract all tags from a repository

use Moose;
use MooseX::LazyRequire;



has 'git'   => ( isa => Object =>, is => ro =>, lazy_build    => 1 );
has 'zilla' => ( isa => Object =>, is => ro =>, lazy_required => 1 );

sub _build_git {
  my ($self) = @_;
  require Dist::Zilla::Util::Git::Wrapper;
  return Dist::Zilla::Util::Git::Wrapper->new( zilla => $self->zilla );
}

sub _mk_tag {
  my ( $self, $name ) = @_;
  require Dist::Zilla::Util::Git::Tags::Tag;
  return Dist::Zilla::Util::Git::Tags::Tag->new(
    name => $name,
    git  => $self->git,
  );
}

sub _for_each_ref {
  my ( $self, $refpragma, $code ) = @_;
  for my $commdata ( $self->git->for_each_ref( $refpragma, '--format=%(objectname) %(refname)' ) ) {
    if ( $commdata =~ qr{ \A ([^ ]+) [ ] refs/tags/ ( .+ ) \z }msx ) {
      $code->( $1, $2 );
      next;
    }
    require Carp;
    Carp::confess( 'Regexp failed to parse a line from `git for-each-ref` :' . $commdata );
  }
  return;
}

sub _mk_tags {
  my ( $self, @tags ) = @_;
  return map { $self->_mk_tag($_) } @tags;
}


sub tags {
  my ($self) = @_;
  return $self->get_tag(q[*]);
}


sub get_tag {
  my ( $self, $name ) = @_;
  my @out;
  $self->_for_each_ref(
    'refs/tags/' . $name => sub {
      my ( $sha1, $tag_name ) = @_;
      push @out, $self->_mk_tag($tag_name);
    }
  );
  return @out;
}


sub tag_sha1_map {
  my ($self) = @_;

  my %hash;
  $self->_for_each_ref(
    'refs/tags/*' => sub {
      my ( $sha1, $name ) = @_;
      if ( not exists $hash{$sha1} ) {
        $hash{$sha1} = [];
      }
      push @{ $hash{$sha1} }, $self->_mk_tag($name);
    }
  );
  return \%hash;
}


sub tags_for_rev {
  my ( $self, $rev ) = @_;
  my (@shas) = $self->git->rev_parse($rev);
  if ( scalar @shas != 1 ) {
    require Carp;
    Carp::croak("Could not resolve a SHA1 from rev $rev");
  }
  my ($sha) = shift @shas;
  my $map = $self->tag_sha1_map;
  return unless exists $map->{$sha};
  return @{ $map->{$sha} };
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Dist::Zilla::Util::Git::Tags - Extract all tags from a repository

=head1 VERSION

version 0.002000

=head1 SYNOPSIS

This tool basically gives a more useful interface around

    git tag

Namely, each tag returned is a tag object, and you can view tag properties with it.

    use Dist::Zilla::Util::Git::Tags;

    my $tags_finder = Dist::Zilla::Util::Git::Tags->new(
        zilla => $self->zilla
    );

    for my $tag ( $tags_finder->tags ) {
        printf "%s - %s\n", $tag->name, $tag->sha1;
    }

=head1 METHODS

=head2 C<tags>

A C<List> of L<< C<::Tags::Tag> objects|Dist::Zilla::Util::Git::Tags::Tag >>

    my @tags = $tag_finder->tags();

=head2 C<get_tag>

    my ($first_matching) = $tags->get_tag('1.000');
    my (@all_matching) = $tags->get_tag('1.*');

Note: This can easily return multiple values.

For instance, C<tags> is implemented as

    my ( @tags ) = $branches->get_tag('*');

Mostly, because the underlying mechanism is implemented in terms of L<< C<fnmatch(3)>|fnmatch(3) >>

If the tag does not exist, or no tag match the expression, C<< get_tag >>  will return an empty list.

So in the top example, C<match> is C<undef> if C<1.000> does not exist.

=head2 C<tag_sha1_map>

A C<HashRef> of C<< sha1 => [ L<< tag|Dist::Zilla::Util::Git::Tags::Tag >>,  L<< tag|Dist::Zilla::Util::Git::Tags::Tag >> ] >> entries.

    my $hash = $tag_finder->tag_sha1_map();

=head2 C<tags_for_rev>

A C<List> of L<< C<::Tags::Tag> objects|Dist::Zilla::Util::Git::Tags::Tag >> that point to the given C<SHA1>.

    $tag_finder->tags_for_rev( $sha1_or_commitish_etc );

=head1 ATTRIBUTES

=head2 C<git>

A Git::Wrapper ( or compatible ) repository.

Auto-Built from C<zilla> with L<< C<::Util::Git::Wrapper>|Dist::Zilla::Util::Git::Wrapper >>

=head2 C<zilla>

A Dist::Zilla instance. Mandatory unless you passed C<git>

=head1 AUTHOR

Kent Fredric <kentfredric@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Kent Fredric <kentfredric@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

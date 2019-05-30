package Pod::SST;

=head1 NAME

Pod::SST - Convert Pod data to Starlink SST prologue.

=head1 SYNOPSIS

  use Pod::SST;
  my $parser = Pod::SST->new();

  $parser->parse_file( $file );

  $parser->write_prologue;

  $prologue = $parser->prologue;

=head1 DESCRIPTION

C<Pod::SST> is a module to convert documentation in the Pod format
into a Starlink SST prologue. The L<B<pod2sst>|pod2sst> X<pod2sst>
command uses this module for translation.

C<Pod::SST> is a derived class from
L<Pod::Simple::Methody|Pod::Simple::Methody>, and thus inherits
methods from L<Pod::Simple|Pod::Simple>.

=cut

use strict;
use warnings;

use Starlink::Prologue;

use Text::Wrap;
$Text::Wrap::columns = 67;

use base qw/ Pod::Simple::Methody /;

use vars qw/ $VERSION /;

$VERSION = '0.01';

use strict;

sub new {
  my $self = shift;
  my $new = $self->SUPER::new(@_);
  $new->{'CurSect'} = '';
  $new->{'CurBuff'} = '';
  $new->{'Indent'} = 0;
  $new->{'Prologue'} = new Starlink::Prologue;
  $new->{'Prologue'}->comment_char( '#' );
  $new->{'Prologue'}->language( "Perl" );
  return $new;
}

sub start_head1 { $_[0]{'CurSect'} = ''; };
sub start_item_bullet {
  my $self = shift;
  if ( $self->{'CurBuff'} =~ /^-  / ) {
    $self->{'CurBuff'} .= "\n";
  }
  $self->{'CurBuff'} .= "-  ";
}

sub start_item_text {
  my $self = shift;
  $self->{'Indent'} --;
  if( $self->{'CurBuff'} ne '' ) {
    $self->{'CurBuff'} .= "\n";
  }
}

sub start_over_text {
  my $self = shift;
  $self->{'Indent'} ++;
}

sub end_item_text {
  my $self = shift;
  $self->{'CurBuff'} .= "\n";
  $self->_update_prologue;
  $self->{'Indent'} ++;
}

sub end_over_text {
  my $self = shift;
  $self->{'Indent'} --;
  $self->{'CurBuff'} .= "\n";
}
sub end_Para { $_[0]->_update_prologue };
sub end_item_bullet { $_[0]->_update_prologue }

sub handle_text {
  my ( $self, $text ) = @_;
  if( $self->{'CurSect'} eq '' ) {
    $self->{'CurSect'} = $text;
    $self->{'CurBuff'} = '';
  } else {
    # Check to see if we're in the 'name' section. If we are, we need
    # to split the text on -- or - to get the 'purpose'.
    if( lc( $self->{'CurSect'} ) eq 'name' ) {
      my ( $name, $purpose ) = split / -{1,2} /, $text;
      $self->{'Prologue'}->name( $name );
      my @purpose = split /\n/, Text::Wrap::wrap( '','',$purpose );
      $self->{'Prologue'}->purpose( @purpose );
      $self->{'CurSect'} = '';
    } else {
      $self->{'CurBuff'} .= $text;
    }
  }
}

sub _update_prologue {
  my $self = shift;

  my $method = lc( $self->{'CurSect'} );
  my $indent = " " x (3 * $self->{'Indent'});
  my @text = split /\n/, Text::Wrap::wrap( $indent,$indent,$self->{'CurBuff'} );

  if( $self->{'Prologue'}->can( "$method" ) ) {
    if( $method eq 'description' &&
        defined( $self->{'Prologue'}->description->[0] ) ) {
      $self->{'Prologue'}->$method( @{$self->{'Prologue'}->$method}, "\n", @text );
    } else {
      $self->{'Prologue'}->$method( @{$self->{'Prologue'}->$method}, @text );
    }
  } else {
    my @stuff = $self->{'Prologue'}->content( $method );
    $self->{'Prologue'}->content( $method, @stuff, @text );
  }
  $self->{'CurBuff'} = '';
}

=head1 METHODS

=item B<prologue>

Returns the L<Starlink::Prologue> object created by parsing the Pod.

  my $prologue = $parser->prologue;

=cut

sub prologue {
  return $_[0]{'Prologue'};
}

=item B<write_prologue>

Prints the SST prologue to STDOUT.

  $parser->write_prologue;

=cut

sub write_prologue {
  print $_[0]{'Prologue'}->stringify;
}

=head1 AUTHOR

Brad Cavanagh E<lt>b.cavanagh@jach.hawaii.eduE<gt>

=head1 COPYRIGHT

Copyright (C) 2007 Science and Technology Facilities Council.  All
Rights Reserved.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful,but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place,Suite 330, Boston, MA 02111-1307,
USA

=cut

1;

#!perl

# A more intensive test of the parser.

# This test reads in the Pod at the end of the file, then does various
# comparisons with the returned Starlink::Prologue object.

use Test::More tests => 23;
use strict;

require_ok( "Pod::SST" );

# Create a parser.
my $parser = Pod::SST->new;
isa_ok( $parser, "Pod::SST" );

# Parse this file.
$parser->parse_file( $0 );

# Retrieve the Starlink::Prologue object.
my $prologue = $parser->prologue;
isa_ok( $prologue, "Starlink::Prologue" );

is( $prologue->name->[0], "JITTER_SELF_FLAT" );

my @purpose = ( 'Reduces a "standard jitter" photometry observation using object',
                'masking.' );
foreach my $i ( 0 .. $#purpose ) {
  is( $prologue->purpose->[$i], $purpose[$i] );
}

my @output_data_section = ( '-  The integrated mosaic in <m><date>_<group_number>_mos, where',
                            '<m> is "gf" for UFTI and "gi" for IRCAM (before 2000 August these',
                            'were "g" and "rg" respectively), "gi" also for IRIS2, "gisaac" for',
                            'ISAAC, and "gingrid" for INGRID.',
                            '-  A mosaic for each cycle of jittered frames in',
                            '<m><date>_<group_number>_mos_c<cycle_number>, where <cycle_number>',
                            'counts from 0.',
                            '-  The individual flat-fielded frames in',
                            '<i><date>_<obs_number>_ff, where <i> is "f" for UFTI, "i" for',
                            'IRCAM, and "isaac" for ISAAC. Before 2000 August IRCAM had prefix',
                            '"ro". IRIS2 data are named <date><obs_number>_ff, where <date> is',
                            'in the form "ddmmm". INGRID files are called r<obs_number>_ff.',
                            '-  For ISAAC, the individual bias-corrected frames in',
                            '<i><date>_<obs_number>_bc.',
                            '-  The created flat fields in flat_<filter>_<group_number> for the',
                            'first or only cycle, and flat_<filter>_<group_number>_c<cycl',
                            'e_number> for subsequent cycles.' );
my @output_data_returned = $prologue->content( 'output data' );
foreach my $i ( 0 .. $#output_data_section ) {
  is( $output_data_returned[$i], $output_data_section[$i] );
}

=head1 NAME

JITTER_SELF_FLAT -- Reduces a "standard jitter" photometry observation
using object masking.

=head1 DESCRIPTION

This script reduces a "standard jitter" photometry observation with
UKIRT imaging data.  It takes an imaging observation comprising
jittered object frames and a dark frame to make a calibrated,
untrimmed mosaic automatically.

It performs a null debiassing, bad-pixel masking, dark subtraction,
flat-field creation and division, feature detection and matching
between object frames, and resampling.  See the L<"NOTES"> for further
information.

This recipe works well for faint sources and for moderately crowded
fields.

=head1 NOTES

=over 4

=item *

A World Co-ordinate System (WCS) using the AIPS convention is created
in the headers should no WCS already exist.

=item *

For IRCAM, old headers are reordered and structured with headings
before groups of related keywords.  The comments have units added or
appear in a standard format.  Four deprecated headers are removed.
FITS-violating headers are corrected.  Spurious instrument names are
changed to IRCAM3.

=item *

The bad-pixel mask applied is F<$ORAC_DATA_CAL/bpm>.

=item *

For INGRID, the pre- and post-exposure images are subtracted.  A
non-linearity correction is then applied.

=item *

The dark-subtracted frame has thresholds applied beyond which pixels
are flagged as bad.  The lower limit is 5 standard deviations below
the mode, but constrained to the range -100 to 1.  The upper limit is
1000 above the saturation limit for the detector in the mode used.

=item *

The flat field is created iteratively.  First an approximate
flat-field is created by combining normalised object frames using the
median at each pixel.  This flat field is applied to the object
frames.  Sources within the flat-fielded frames are detected, and
masked in the dark-subtracted frames.  The first stage is repeated but
applied to the masked frames to create the final flat field.

=item *

For ISAAC, residual bias variations along the columns are largely
removed from each flat-fielded frame.  The recipe first masks the
sources, then collapses the frame along its rows to form a profile,
whose clipped mean is subtracted.  The resultant profile reflects the
bias variations.  The recipe subtracts this profile from each column
of the flat-fielded frame.

=item *

The field distortion of ISAAC is corrected using the mappings
documented on the ISAAC problems web page.

=item *

Registration is performed using common point sources in the overlap
regions.  If the recipe cannot identify sufficient common objects, the
script resorts to using the telescope offsets transformed to pixels.

=item *

The resampling applies non-integer shifts of origin using bilinear
interpolation.  There is no rotation to align the Cartesian axes with
the cardinal directions.

=item *

The recipe makes the mosaics by applying offsets in intensity to give
the most consistent result amongst the overlapping regions.  The
mosaic is not trimmed to the dimensions of a single frame, thus the
noise will be greater in the peripheral areas having received less
exposure time.  The mosaic is not normalised by its exposure time
(that being the exposure time of a single frame).

=item *

For each cycle of jittered frames, the recipe creates a mosaic, which
has its bad pixels filled and is then added into a master mosaic of
improving signal to noise.  The exposure time is also summed and
stored in the mosaic's corresponding header.  Likewise the end airmass
and end UT headers are updated to match that of the last-observed
frame contributing to the mosaic.

=item *

Intermediate frames are deleted except for the flat-fielded (_ff
suffix) frames.

=back

=head1 OUTPUT DATA

=over 4

=item *

The integrated mosaic in
E<lt>mE<gt>E<lt>dateE<gt>_E<lt>group_numberE<gt>_mos, where
E<lt>mE<gt> is "gf" for UFTI and "gi" for IRCAM (before 2000 August
these were "g" and "rg" respectively), "gi" also for IRIS2, "gisaac"
for ISAAC, and "gingrid" for INGRID.

=item *

A mosaic for each cycle of jittered frames in
E<lt>mE<gt>E<lt>dateE<gt>_E<lt>group_numberE<gt>_mos_cE<lt>cycle_numberE<gt>,
where E<lt>cycle_numberE<gt> counts from 0.

=item *

The individual flat-fielded frames in
E<lt>iE<gt>E<lt>dateE<gt>_E<lt>obs_numberE<gt>_ff, where E<lt>iE<gt>
is "f" for UFTI, "i" for IRCAM, and "isaac" for ISAAC.  Before 2000
August IRCAM had prefix "ro".  IRIS2 data are named
E<lt>date>E<lt>obs_numberE<gt>_ff, where E<lt>dateE<gt> is in the form
"ddmmm".  INGRID files are called rE<lt>obs_numberE<gt>_ff.

=item *

For ISAAC, the individual bias-corrected frames in
E<lt>iE<gt>E<lt>dateE<gt>_E<lt>obs_numberE<gt>_bc.

=item *

The created flat fields in
flat_E<lt>filterE<gt>_E<lt>group_numberE<gt> for the first or only
cycle, and flat_E<lt>filterE<gt>_E<lt>group_numberE<gt>_cE<lt>cycl
e_numberE<gt> for subsequent cycles.

=back

=head1 CONFIGURABLE STEERING PARAMETERS

=over 4

=item NUMBER = INTEGER

The number of frames in the jitter pattern.  If not supplied the
number of offsets, as given by FITS header NOFFSETS, minus one is
used.  If neither is available, 9 is the default.  An error state
arises if the number of jittered frames is fewer than 3.  For
observations prior to the availability of full ORAC, NOFFSETS will be
absent.  []

=item USEVAR = LOGICAL

Whether or not to create and propagate variance arrays.  [0]

=back

=head1 IMPLEMENTATION STATUS

=over 4

=item *

The processing engines are from the Starlink packages: CCDPACK, KAPPA,
FIGARO, and EXTRACTOR.

=item *

Uses the Starlink NDF format.

=item *

History is recorded within the data files.

=item *

The title of the data is propagated through intermediate files
to the mosaic.

=item *

Error propagation is controlled by the USEVAR parameter.

=back

=head1 RELATED RECIPES

L<JITTER_SELF_FLAT_APHOT|JITTER_SELF_FLAT_APHOT>,
L<JITTER_SELF_FLAT_BASIC|JITTER_SELF_FLAT_BASIC>,
L<JITTER_SELF_FLAT_NO_MASK|JITTER_SELF_FLAT_NO_MASK>,
L<JITTER_SELF_FLAT_TELE|JITTER_SELF_FLAT_TELE>,
L<MOVING_JITTER_SELF_FLAT_TELE|MOVING_JITTER_SELF_FLAT_TELE>,
L<QUADRANT_JITTER|QUADRANT_JITTER>.

=head1 REFERENCES

"I<Scripts for UFTI>" G.S. Wright & S.K. Leggett, 1997 orac009-ufts,
v01.

=head1 AUTHORS

Malcolm J. Currie (UKATC/JAC) (mjc@jach.hawaii.edu)

=head1 COPYRIGHT

Copyright (C) 1998-2003 Particle Physics and Astronomy Research
Council.  All Rights Reserved.

=cut

# Makefile for Pod::LaTeX

use ExtUtils::MakeMaker;

# Write the makefile
WriteMakefile(
              'NAME'      => 'Pod::SST',
              'VERSION_FROM' => 'SST.pm',
              'EXE_FILES' => [ 'pod2sst' ],
              'PREREQ_PM' => {
                              Pod::Simple::Methody => 0,
                              Starlink::Prologue => 0,
                              Text::Wrap => 0,
                             },
              'dist'      => { COMPRESS => "gzip -9f" },
              ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
               (ABSTRACT_FROM => 'SST.pm',
                AUTHOR     => 'Brad Cavanagh <b.cavanagh@jach.hawaii.edu>') : ()),
);

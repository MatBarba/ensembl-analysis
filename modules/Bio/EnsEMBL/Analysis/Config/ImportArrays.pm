#
# package Bio::EnsEMBL::Analysis::Config::ImportArrays
# 
# Cared for by EnsEMBL (ensembl-dev@ebi.ac.uk)
#
# Copyright GRL & EBI
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::EnsEMBL::Analysis::Config::ImportArrays

=head1 SYNOPSIS

    use Bio::EnsEMBL::Analysis:Config::ImportAarrys;

=head1 DESCRIPTION

This contains the configuration for importing arrays from flat files.
It is entirely dependant on the arrays.env environment which can be used 
to set up and run the pipeline in an easy and interactive way. This contains 
all possible configurations which will then be set dynamically by the RunnableDB
for each instance using the input_id as a key into a separate ImportArrays.conf 
file, listed here as ARRAY_FORMAT_FILE.


The layout of the configuration is a set of hashes,
each one keyed by logic name. There is also a DEFAULT hash,
which is used as the default for all logic names (this
was the configuration pattern stolen from Exonerate2Genes,
although in this case it's very unlikely you will need to have
different configs by logic name).

=head1 CONTACT

=cut


package Bio::EnsEMBL::Analysis::Config::ImportArrays;

use strict;
use vars qw( %Config );

# Hash containing config info
# -- one hashnode per logic name, with a 'DEFAULT' logic name provided
#

%Config = 
  (

   #This entire hash is exported as the global $ARRAY_CONFIG var
   #each key will be exported as $ARRAY_CONFIG->{'_CONFIG_'.$key}
   #Dependant on logic name of RunnableDB

   ARRAY_CONFIG => 
   {
	DEFAULT => 
	{
	 #These are now defined dynamically or via the ImportArrays.conf file
	 # All input probes must be kept in one huge (possibly redundant) fasta file
	 #QUERYSEQS            => $ENV{'RAW_FASTA'},
	 # The output of this module writes a set of affy probes into the OUTDB.affy_probe table,
	 # and also writes the nonredundant probes into this fasta file,
	 # with the fasta headers keyed with the affy probes' internal id. 
	 #NON_REDUNDANT_PROBE_SEQS => $ENV{'NR_FASTA'},
	 
	 # DB containing all affy_arrays, affy_probes and (next step) affy_features
	 OUTDB => {
			   -dbname => $ENV{'DB_NAME'},
			   -host   => $ENV{'DB_HOST'},
			   -port   => $ENV{'DB_PORT'},
			   -user   => $ENV{'DB_USER'},
			   -pass   => $ENV{'DB_PASS'},
			   -species => $ENV{'SPECIES'},#Only here until we fix the DBAadptor new method
			  },


	 #Optional, must define if dnadb is not on ensembldb
	 #Not used, but will fail if dnadb autoguessing fails
	 DNADB => {
			   -dbname => $ENV{'DNADB_NAME'},
			   -host   => $ENV{'DNADB_HOST'},
			   -port   => $ENV{'DNADB_PORT'},
			   -user   => $ENV{'DNADB_USER'},
			   -pass   => $ENV{'DNADB_PASS'},
			   -species => $ENV{'SPECIES'},
			  },
	 
	 #Used for building the format specific NR fasta file
	 OUTPUT_DIR           => $ENV{'WORK_DIR'},


	 #This defines how to parse the file headers
	 IIDREGEXP =>  '^>probe:(\S+):(\S+):(\S+:\S+;).*$',#AFFY
				  
	 #We also need a has to define the input field order
	 #This will be used to set the relevant hash values
	 IFIELDORDER => {
					 #do we need to add fields for class to enable skipping on control probes
					 #here and in regexp
					 #We duplicate the field 0 between array.name and array_chip.design_id
					 #-name       => 2,
					 #-array      => 0,
					 #-array_chip => 0,
					 #-probeset   => 1,
					},

	 #ISKIPLIST/REGEX
	 #ISKIPFIELD



	 

	 ARRAY_PARAMS => {
					  #'MG-U74Cv2' => {
					#				  -name => 'MG-U74Cv2',
					#				  -vendor => 'AFFY',
					#				  #-setsize => undef,
					#				  -format  => 'EXPRESSION',
					#				  -type    => 'OLIGO', 
					  #  -class => 'AFFY_ST',
					#				  #-description => '',
					#				 },

					 # 'MoGene-1_0-st-v1' => {
					#						 -name => 'MoGene-1_0-st-v1',
					#						 -vendor => 'AFFY',
					#						 #-setsize => undef,
					#						 -format  => 'EXPRESSION',
					#						 -type    => 'OLIGO',
					#						 #-description => '',
					  #  -class => 'AFFY_ST',
					#						},


					 },

	 
	},


	#%{$Config::ArrayMapping::import_arrays},

	IMPORT_AFFY_UTR_ARRAYS => 
	{
	 IIDREGEXP => '^>probe:(\S+):(\S+):(\S+:\S+;).*$',
	 
	 IFIELDORDER => {
					 -name       => 2, -array_chip => 0,
					 -array      => 0, -probeset   => 1
					},
 	 
	 #Can we remove name from these hashes?

	 ARRAY_PARAMS => 
	 {
	  'MG-U74Cv2' => {
					  -name => 'MG-U74Cv2',
					  -vendor => 'AFFY',
					  -format  => 'EXPRESSION',
					  -type    => 'OLIGO',
					  #-description => '',
					  -class   => 'AFFY_UTR',
					 },


	   'MG-U74A' => {
					  -name => 'MG-U74A',
					  -vendor => 'AFFY',
					  -format  => 'EXPRESSION',
					  -type    => 'OLIGO',
					  #-description => '',
					  -class   => 'AFFY_UTR',
					  
					 },
	  
	  'MG-U74Av2' => {
					  -name => 'MG-U74Av2',
					  -vendor => 'AFFY',
					  -format  => 'EXPRESSION',
					  -type    => 'OLIGO',
					  #-description => '',
					  -class   => 'AFFY_UTR',
					 },
	  


	   'MG-U74B' => {
					  -name => 'MG-U74B',
					  -vendor => 'AFFY',
					  -format  => 'EXPRESSION',
					  -type    => 'OLIGO',
					  #-description => '',
					  -class   => 'AFFY_UTR',
					},
	  
	  'MG-U74Bv2' => {
					  -name => 'MG-U74Bv2',
					  -vendor => 'AFFY',
					  -format  => 'EXPRESSION',
					  -type    => 'OLIGO',
					  #-description => '',
					  -class   => 'AFFY_UTR',
					},
	  

 'MG-U74C' => {
					  -name => 'MG-U74C',
					  -vendor => 'AFFY',
					  -format  => 'EXPRESSION',
					  -type    => 'OLIGO',
					  #-description => '',
					  -class   => 'AFFY_UTR',
					},

	   'MOE-430A' => {
					  -name => 'MOE-430A',
					  -vendor => 'AFFY',
					  -format  => 'EXPRESSION',
					  -type    => 'OLIGO',
					  #-description => '',
					  -class   => 'AFFY_UTR',
					},

 'MOE-430B' => {
					  -name => 'MOE-430B',
					  -vendor => 'AFFY',
					  -format  => 'EXPRESSION',
					  -type    => 'OLIGO',
					  #-description => '',
					  -class   => 'AFFY_UTR',
					},

	   'MOE-430A_2' => {
					  -name => 'MOE-430A_2',
					  -vendor => 'AFFY',
					  -format  => 'EXPRESSION',
					  -type    => 'OLIGO',
					  #-description => '',
					  -class   => 'AFFY_UTR',
					},

	  
  'MOE-430_2' => {
					  -name => 'MOE-430_2',
					  -vendor => 'AFFY',
					  -format  => 'EXPRESSION',
					  -type    => 'OLIGO',
					  #-description => '',
					  -class   => 'AFFY_UTR',
					},



	    'Mu11KsubA' => {
					  -name => 'Mu11LsubA',
					  -vendor => 'AFFY',
					  -format  => 'EXPRESSION',
					  -type    => 'OLIGO',
					  #-description => '',
					  -class   => 'AFFY_UTR',
					},
   'Mu11KsubB' => {
					  -name => 'Mu11LsubB',
					  -vendor => 'AFFY',
					  -format  => 'EXPRESSION',
					  -type    => 'OLIGO',
					  #-description => '',
					  -class   => 'AFFY_UTR',
					},


	
	  'HT_MG-430A' => {
					   -name => 'HT_MG-430A',
					  -vendor => 'AFFY',
					  #-setsize => undef,
					  -format  => 'EXPRESSION',#? UTR?
					  -type    => 'OLIGO',
					  #-description => '',
					   -class   => 'AFFY_UTR',
					 },

	  'S_aureus' => {
					 -name => 'S_aureus',
					 -vendor => 'AFFY',
					 #-setsize => undef,
					 -format  => 'EXPRESSION',#? UTR?
					 -type    => 'OLIGO',
					 #-description => '',
					 -class   => 'AFFY_UTR',
					},

	  #Then add user defined/custom ones here?
	  #values %{$ArrayConfig->{ARRAY_PARAMS}}
	  #Could write this automatically from env or script?

	 },
	 
	 INPUT_FORMAT => 'FASTA',
	},

	IMPORT_AFFY_ST_ARRAYS => 
	{
	 IIDREGEXP => '^>probe:(\S+):(\S+);\S+:\S+;.*[TranscriptCluster|ProbeSet]ID=([0-9]+);.*$',
	 
	 IFIELDORDER => {
					 -name       => 1,
					 -array_chip => 0,
					 -array      => 0,
					 -probeset   => 2,
					},
	 	 
	 ARRAY_PARAMS => {
					  
					  'MoGene-1_0-st-v1' => {
											 -name => 'MoGene-1_0-st-v1',
											 -vendor => 'AFFY',
											 #-setsize => undef,
											 -format  => 'EXPRESSION',
											 -type    => 'OLIGO',
											 #-description => '',
											 -class   => 'AFFY_ST',
											},


					  'MoEx-1_0-st-v1' => {
										   -name => 'MoEx-1_0-st-v1',
										   -vendor => 'AFFY',
										   -format  => 'EXPRESSION',
										   -type    => 'OLIGO',
										   #-description => '',
										   -class   => 'AFFY_ST',
										  },
					  


										   },
	 
	 INPUT_FORMAT => 'FASTA',
	},

	IMPORT_ILLUMINA_WG_ARRAYS => 
	{
	 IIDREGEXP => '^>(\S+):(\S+).*$',
	 
	 IFIELDORDER => {
					 -name       => 1,
					 -array_chip => 0,
					 -array      => 0,
					 #-probeset   => 2,#This could be annotation
					},
	 	 
	 ARRAY_PARAMS => {
					  
					  'MouseWG_6_V1' => {
										 -name => 'MouseWG_6_V1',
										 -vendor => 'ILLUMINA',
										 #-setsize => undef,
										 -format  => 'EXPRESSION',
										 -type    => 'OLIGO',
										 #-description => '',
										  -class   => 'ILLUMINA_WG',
										},
					  
					  
					  'MouseWG_6_V2' => {
										 -name => 'MouseWG_6_V2',
										 -vendor => 'ILLUMINA',
										 #-setsize => undef,
										 -format  => 'EXPRESSION',
										 -type    => 'OLIGO',
										 #-description => '',
										  -class   => 'ILLUMINA_WG',
										},
					  
					  'HumanWG_6_V1' => {
										 -name => 'HumanWG_6_V1',
										 -vendor => 'ILLUMINA',
										 #-setsize => undef,
										 -format  => 'EXPRESSION',
										 -type    => 'OLIGO',
										 #-description => '',
										  -class   => 'ILLUMINA_WG',
										},

					  'HumanWG_6_V2' => {
										 -name => 'HumanWG_6_V2',
										 -vendor => 'ILLUMINA',
										 #-setsize => undef,
										 -format  => 'EXPRESSION',
										 -type    => 'OLIGO',
										 #-description => '',
										  -class   => 'ILLUMINA_WG',
										},

					  'HumanWG_6_V3' => {
										 -name => 'HumanWG_6_V3',
										 -vendor => 'ILLUMINA',
										 #-setsize => undef,
										 -format  => 'EXPRESSION',
										 -type    => 'OLIGO',
										 #-description => '',
										  -class   => 'ILLUMINA_WG',
										},
					  
					  

					 },
	 
	 INPUT_FORMAT => 'FASTA',
	},


	

	#ILLUMINA
	#ILLUMINA_V1
	#ILLUMINA_V2
	#CODELINK
	#AGILENT
	#?
   
#Human

#ftp://ftp.phalanxbiotech.com/pub/probe_sequences/hoa

#Mouse

#ftp://ftp.phalanxbiotech.com/pub/probe_sequences/moa

   }
  );

sub import {
  my ($callpack) = caller(0); # Name of the calling package
  my $pack = shift; # Need to move package off @_

  # Get list of variables supplied, or else everything
  my @vars = @_ ? @_ : keys( %Config );
  return unless @vars;
  
  # Predeclare global variables in calling package
  eval "package $callpack; use vars qw("
    . join(' ', map { '$'.$_ } @vars) . ")";
    die $@ if $@;


    foreach (@vars) {
	if ( defined $Config{$_} ) {
            no strict 'refs';
	    # Exporter does a similar job to the following
	    # statement, but for function names, not
	    # scalar variables:
	    *{"${callpack}::$_"} = \$Config{ $_ };
	} else {
	    die "Error: Config: $_ not known\n";
	}
    }
}

1;

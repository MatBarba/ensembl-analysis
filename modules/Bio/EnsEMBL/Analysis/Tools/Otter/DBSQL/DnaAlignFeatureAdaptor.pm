# Copyright [1999-2016] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#      http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

=head1 NAME

Bio::EnsEMBL::Analysis::Tools::Otter::DBSQL::DnaAlignFeatureAdaptor - Adaptor for DnaAlignFeatures

=head1 SYNOPSIS

  $dafa = $registry->get_adaptor( 'Human', 'Core', 'DnaAlignFeature' );

  my @features = @{ $dafa->fetch_all_by_Slice($slice) };

  $dafa->store(@features);

=head1 DESCRIPTION

This is an adaptor responsible for the retrieval and storage of 
DnaDnaAlignFeatures from the Otter database. This adaptor inherits most of its 
functionality from the DnaAlignFeatureAdaptor, BaseAlignFeatureAdaptor and BaseFeatureAdaptor 
superclasses.

The module inherits all methods from DnaAlignFeatureAdaptor EXCEPT that
it overrides the _objs_from_sth method to include dna_align_feature_history 
and there is a new method, fetch_all_by_Slice_attach_daf_history.

=head1 CONTACT

Post questions to the EnsEMBL development list <http://lists.ensembl.org/mailman/listinfo/dev>

=cut

package Bio::EnsEMBL::Analysis::Tools::Otter::DBSQL::DnaAlignFeatureAdaptor;
use warnings ;
use vars qw(@ISA);
use strict;
use Bio::EnsEMBL::DBSQL::DnaAlignFeatureAdaptor;
use Bio::EnsEMBL::Utils::Exception qw(throw warning);

@ISA = qw(Bio::EnsEMBL::DBSQL::DnaAlignFeatureAdaptor);

sub fetch_all_by_Slice_attach_daf_history {
  # need to modify this method so that we fetch the dna_align_feature_history too
  my ($self, $slice, $logic_name) = @_;
  return $self->fetch_all_by_Slice($slice, $logic_name);
}


=head2 _objs_from_sth

  Arg [1]    : DBI statement handle $sth
               an exectuted DBI statement handle generated by selecting
               the columns specified by _columns() from the table specified
               by _table()
  Example    : @dna_dna_align_feats = $self->_obj_from_hashref
  Description: PROTECTED implementation of superclass abstract method.
               Creates DnaDnaAlignFeature objects from a DBI hashref
  Returntype : listref of Bio::EnsEMBL::DnaDnaAlignFeatures
  Exceptions : none
  Caller     : Bio::EnsEMBL::BaseFeatureAdaptor::generic_fetch
  Status     : Stable

=cut

sub _objs_from_sth {
  my ($self, $sth, $mapper, $dest_slice) = @_;

  my @features;
  my %analysis_hash;
  my %slice_hash;
  my %sr_name_hash;
  my %sr_cs_hash;

  my($dna_align_feature_id, $seq_region_id, $analysis_id, $seq_region_start,
     $seq_region_end, $seq_region_strand, $hit_start, $hit_end, $hit_name,
     $hit_strand, $cigar_line, $evalue, $perc_ident, $score,
     $external_db_id, $hcoverage, $extra_data, 
     $external_db_name, $external_display_db_name);

  $sth->bind_columns(
    \$dna_align_feature_id, \$seq_region_id, \$analysis_id, \$seq_region_start,
    \$seq_region_end, \$seq_region_strand, \$hit_start, \$hit_end, \$hit_name,
    \$hit_strand, \$cigar_line, \$evalue, \$perc_ident, \$score,
    \$external_db_id, \$hcoverage, \$extra_data,
     \$external_db_name, \$external_display_db_name);

  my $sa = $dest_slice ? $dest_slice->adaptor() : $self->db()->get_SliceAdaptor();;
  my $aa = $self->db->get_AnalysisAdaptor();
  my $dafha = $self->db->get_DnaAlignFeatureHistoryAdaptor($seq_region_id,$analysis_id,$dna_align_feature_id);

  my $asm_cs;
  my $cmp_cs;
  my $asm_cs_vers;
  my $asm_cs_name;
  my $cmp_cs_vers;
  my $cmp_cs_name;
  if($mapper) {
    $asm_cs = $mapper->assembled_CoordSystem();
    $cmp_cs = $mapper->component_CoordSystem();
    $asm_cs_name = $asm_cs->name();
    $asm_cs_vers = $asm_cs->version();
    $cmp_cs_name = $cmp_cs->name();
    $cmp_cs_vers = $cmp_cs->version();
  }

  my $dest_slice_start;
  my $dest_slice_end;
  my $dest_slice_strand;
  my $dest_slice_length;
  my $dest_slice_sr_name;
  my $dest_slice_seq_region_id;

  if($dest_slice) {
    $dest_slice_start  = $dest_slice->start();
    $dest_slice_end    = $dest_slice->end();
    $dest_slice_strand = $dest_slice->strand();
    $dest_slice_length = $dest_slice->length();
    $dest_slice_sr_name = $dest_slice->seq_region_name();
    $dest_slice_seq_region_id = $dest_slice->get_seq_region_id();
  }

  FEATURE: while($sth->fetch()) {
    #get the analysis object
    my $analysis = $analysis_hash{$analysis_id} ||=
      $aa->fetch_by_dbID($analysis_id);

    my $dna_align_feature_history = $dafha->fetch_by_DnaAlignFeature_info($dna_align_feature_id, $seq_region_id, $analysis_id);

    #get the slice object
    my $slice = $slice_hash{"ID:".$seq_region_id};

    if(!$slice) {
      $slice = $sa->fetch_by_seq_region_id($seq_region_id);
      $slice_hash{"ID:".$seq_region_id} = $slice;
      $sr_name_hash{$seq_region_id} = $slice->seq_region_name();
      $sr_cs_hash{$seq_region_id} = $slice->coord_system();
    }

    my $sr_name = $sr_name_hash{$seq_region_id};
    my $sr_cs   = $sr_cs_hash{$seq_region_id};
   
    #
    # remap the feature coordinates to another coord system
    # if a mapper was provided
    #
    if($mapper) {

      ($seq_region_id,$seq_region_start,$seq_region_end,$seq_region_strand) =
        $mapper->fastmap($sr_name, $seq_region_start, $seq_region_end,
                          $seq_region_strand, $sr_cs);

      #skip features that map to gaps or coord system boundaries
      next FEATURE if(!defined($seq_region_id));

      #get a slice in the coord system we just mapped to
      if($asm_cs == $sr_cs || ($cmp_cs != $sr_cs && $asm_cs->equals($sr_cs))) {
        $slice = $slice_hash{"ID:".$seq_region_id} ||=
          $sa->fetch_by_seq_region_id($seq_region_id);
      } else {
        $slice = $slice_hash{"ID:".$seq_region_id} ||=
          $sa->fetch_by_seq_region_id($seq_region_id);
      }
    }

    #
    # If a destination slice was provided convert the coords
    # If the dest_slice starts at 1 and is foward strand, nothing needs doing
    #
    if($dest_slice) {
      if($dest_slice_start != 1 || $dest_slice_strand != 1) {
        if($dest_slice_strand == 1) {
          $seq_region_start = $seq_region_start - $dest_slice_start + 1;
          $seq_region_end   = $seq_region_end   - $dest_slice_start + 1;
        } else {
          my $tmp_seq_region_start = $seq_region_start;
          $seq_region_start = $dest_slice_end - $seq_region_end + 1;
          $seq_region_end   = $dest_slice_end - $tmp_seq_region_start + 1;
          $seq_region_strand *= -1;
        }

        #throw away features off the end of the requested slice
        if($seq_region_end < 1 || $seq_region_start > $dest_slice_length ||
          ( $dest_slice_seq_region_id ne $seq_region_id ))  {
          next FEATURE;
        }
      }
      $slice = $dest_slice;
    }

    # Finally, create the new DnaAlignFeature.
    # not that we can't use create_fast
    # and also we must write our keys as eg. -slice and not as eg. 'slice'
    # or it will confuse Feature.pm and pass incorrect values
    push( @features,
          $self->_create_feature(
                                  'Bio::EnsEMBL::Analysis::Tools::Otter::DnaAlignFeature', {
                                    -slice           => $slice,
                                    -start           => $seq_region_start,
                                    -end             => $seq_region_end,
                                    -strand          => $seq_region_strand,
                                    -hseqname        => $hit_name,
                                    -hstart          => $hit_start,
                                    -hend            => $hit_end,
                                    -hstrand         => $hit_strand,
                                    -score           => $score,
                                    -p_value         => $evalue,
                                    -percent_id      => $perc_ident,
                                    -cigar_string    => $cigar_line,
                                    -analysis        => $analysis,
                                    -adaptor         => $self,
                                    -dbID            => $dna_align_feature_id,
                                    -external_db_id  => $external_db_id,
                                    -hcoverage       => $hcoverage,
                                    -extra_data      => $extra_data ? $self->get_dumped_data($extra_data) : '',
                                    -dbname          => $external_db_name,
                                    -db_display_name => $external_display_db_name,
                                    -dna_align_feature_history => $dna_align_feature_history,
                                  } ) );

  }

  return \@features;
}
 
1;



# nameID
# relatedNameID
# type
# referenceID
# remarks
#
module Export::Coldp::Files::NameRelation

  # These concepts do not really fit with the CoL Name/NameRelation data model or are represented in a different way
  # TODO: SupressedSynony misspelled in TW models, which probably should be SupressedSynonym
  BLOCKED = %w[TaxonNameRelationship::CurrentCombination
               TaxonNameRelationship::Combination
               TaxonNameRelationship::Combination::Family
               TaxonNameRelationship::Combination::Genus
               TaxonNameRelationship::Combination::Subgenus
               TaxonNameRelationship::Combination::Species
               TaxonNameRelationship::Combination::Subspecies
               TaxonNameRelationship::Combination::Variety
               TaxonNameRelationship::Combination::Subvariety
               TaxonNameRelationship::Combination::Series
               TaxonNameRelationship::Combination::Subseries
               TaxonNameRelationship::Combination::Section
               TaxonNameRelationship::Combination::Subsection
               TaxonNameRelationship::Combination::Form
               TaxonNameRelationship::Combination::Subform
               TaxonNameRelationship::OriginalCombination
               TaxonNameRelationship::OriginalCombination::Original
               TaxonNameRelationship::OriginalCombination::OriginalGenus
               TaxonNameRelationship::OriginalCombination::OriginalSubgenus
               TaxonNameRelationship::OriginalCombination::OriginalSpecies
               TaxonNameRelationship::OriginalCombination::OriginalSubspecies
               TaxonNameRelationship::OriginalCombination::OriginalVariety
               TaxonNameRelationship::OriginalCombination::OriginalSubvariety
               TaxonNameRelationship::OriginalCombination::OriginalForm
               TaxonNameRelationship::OriginalCombination::OriginalSubform
               TaxonNameRelationship::SourceClassifiedAs
               TaxonNameRelationship::Iczn::Invalidating
               TaxonNameRelationship::Iczn::Invalidating::Suppression::Total
               TaxonNameRelationship::Iczn::Invalidating::Misapplication
               TaxonNameRelationship::Iczn::Invalidating::Synonym
               TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective
               TaxonNameRelationship::Iczn::Invalidating::Usage
               TaxonNameRelationship::Iczn::PotentiallyValidating
               TaxonNameRelationship::Iczn::Validating
               TaxonNameRelationship::Iczn::Validating::UncertainPlacement
               TaxonNameRelationship::Icnp::Accepting
               TaxonNameRelationship::Icnp::Unaccepting
               TaxonNameRelationship::Icnp::Unaccepting::Synonym
               TaxonNameRelationship::Icnp::Unaccepting::SupressedSynonym
               TaxonNameRelationship::Icnp::Unaccepting::Usage
               TaxonNameRelationship::Icn::Accepting
               TaxonNameRelationship::Icn::Unaccepting
               TaxonNameRelationship::Icn::Unaccepting::Synonym
               TaxonNameRelationship::Icn::Unaccepting::Synonym::Heterotypic
               TaxonNameRelationship::Icn::Unaccepting::Usage
               TaxonNameRelationship::Icvcn::Accepting
               TaxonNameRelationship::Icvcn::Accepting::UncertainPlacement
               TaxonNameRelationship::Icvcn::Unaccepting
               TaxonNameRelationship::Hybrid].freeze

  def self.type(tnr)
    if tnr.type.include? "TaxonNameRelationship::Typification"  # There are no nomen_uri's for Typification
      type = "type"
    else
      type = tnr.type.constantize.nomen_uri
    end
    type
  end


  def self.generate(otus, reference_csv = nil )
    Current.project_id = otus[0].project_id
    CSV.generate(col_sep: "\t") do |csv|

      csv << %w{
        nameID
        relatedNameID
        type
        referenceID
        remarks
      }

      TaxonNameRelationship.where(project_id: Current.project_id).each do |tnr|

        # Combinations and OriginalCombinations are already handled in the Name module
        unless BLOCKED.include? tnr.type

          sources = tnr.sources.load
          reference_ids = sources.collect{|a| a.id}
          reference_id = reference_ids.first

          csv << [
            tnr.subject_taxon_name_id,                                # nameID
            tnr.object_taxon_name_id,                                 # relatedNameID
            type(tnr),                                                # type
            reference_id,                                             # referenceID
            nil,                                                      # remarks
          ]

          Export::Coldp::Files::Reference.add_reference_rows(sources, reference_csv) if reference_csv

        end
      end
    end
  end
end

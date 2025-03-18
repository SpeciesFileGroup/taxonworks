# nameID
# relatedNameID
# type
# referenceID
# remarks
#
module Export::Coldp::Files::NameRelation

  # Documentation: http://api.checklistbank.org/vocab/nomreltype

  # These concepts do not really fit with the CoL Name/NameRelation data model or are represented in a different way
  # TODO: SupressedSynony misspelled in TW models, which probably should be SupressedSynonym
  BLOCKED = %w[TaxonNameRelationship::Typification
               TaxonNameRelationship::CurrentCombination
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


  def self.generate(otus, project_members, reference_csv = nil )
    ::CSV.generate(col_sep: "\t") do |csv|

      csv << %w{
        nameID
        relatedNameID
        type
        referenceID
        modified
        modifiedBy
        remarks
      }

      otus.each do |o|
        o.taxon_name.related_taxon_name_relationships.each do |tnr|

          # Combinations and OriginalCombinations are already handled in the Name module
          unless (tnr.type.constantize.nomen_uri.blank? || BLOCKED.include?(tnr.type))

            sources = tnr.sources.load
            reference_ids = sources.collect{|a| a.id}
            reference_id = reference_ids.first

            csv << [
              tnr.subject_taxon_name_id,                                       # nameID
              tnr.object_taxon_name_id,                                        # relatedNameID
              tnr.type.constantize.nomen_uri,                                  # type
              reference_id,                                                    # referenceID
              Export::Coldp.modified(tnr[:updated_at]),                        # modified
              Export::Coldp.modified_by(tnr[:updated_by_id], project_members), # modified_by
              nil,                                                             # remarks
            ]

            Export::Coldp::Files::Reference.add_reference_rows(sources, reference_csv, project_members) if reference_csv
          end
        end
      end
    end
  end
end

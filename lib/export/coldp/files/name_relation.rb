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
  BLOCKED = %w{
    TaxonNameRelationship::Typification
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
    TaxonNameRelationship::Hybrid
  }.freeze

  # TODO: This is the original set, but it doesn't quite feel right.
  def self.taxon_name_relationships(otus)

    # TODO: Join in proper name methods, don't rely on OTU scope
    a = TaxonNameRelationship.with(otu_scope: otus.select(:id, :taxon_name_id))
      .joins("JOIN taxon_names obj_tn on obj_tn.id = taxon_name_relationships.object_taxon_name_id")
      .joins("JOIN otu_scope on otu_scope.taxon_name_id = obj_tn.id")
      .left_joins(:sources)
      .where.not(taxon_name_relationships: {type: BLOCKED})
      .group('taxon_name_relationships.id')
      .select("taxon_name_relationships.*, MAX(sources.id) a_source_id")
  end

  def self.generate(otus, project_members, reference_csv = nil )
    rels = nil
    text = ::CSV.generate(col_sep: "\t") do |csv|

      csv << %w{
        nameID
        relatedNameID
        type
        referenceID
        modified
        modifiedBy
        remarks
      }

      rels = taxon_name_relationships(otus)
      rels.length

      rels.each do |tnr|

        next if ::Export::Coldp.skipped_combinations.include?(tnr.subject_taxon_name_id)

        unless tnr.type.constantize.nomen_uri.blank?
          csv << [
            tnr.subject_taxon_name_id,                                       # nameID
            tnr.object_taxon_name_id,                                        # relatedNameID
            tnr.type.constantize.nomen_uri,                                  # type
            tnr.a_source_id,                                                 # referenceID
            Export::Coldp.modified(tnr[:updated_at]),                        # modified
            Export::Coldp.modified_by(tnr[:updated_by_id], project_members), # modified_by
            nil,                                                             # remarks
          ]
        end
      end
    end
    sources = []

    sources = Source.with(name_scope: rels)
      .joins(:citations)
      .joins("JOIN name_scope ns on ns.id = citations.citation_object_id AND citations.citation_object_type = 'TaxonNameRelationship'")
      .distinct

    Export::Coldp::Files::Reference.add_reference_rows(sources, reference_csv, project_members) if reference_csv && sources.any?
    text
  end
end

# taxonID
# relatedTaxonID
# relatedTaxonScientificName
# type
# referenceID
# remarks
#
module Export::Coldp::Files::SpeciesInteraction

  def self.biological_association_indices(otus)
    b = BiologicalAssociationIndex
      .with(otus:)
      .joins("JOIN otus on otus.id = biological_association_indices.subject_id and biological_association_indices.subject_type = 'Otu'")
      .left_joins(biological_association: [:sources])
      .group('biological_association_id, subject_id, object_label, relationship_name, biological_association_indices.id, biological_associations.updated_at, biological_associations.updated_by_id, sources.id')
      .order('biological_association_id, sources.cached_nomenclature_date')
      .select(
        %w{
         biological_association_indices.id
         subject_id
         object_label
         relationship_name
         MAX(sources.id)\ AS\ source_id
         sources.cached_nomenclature_date
         biological_associations.updated_at
         biological_associations.updated_by_id
        }.join(', ')
      )
  end

  def self.generate(otus, project_members, reference_csv = nil )
    CSV.generate(col_sep: "\t") do |csv|

      csv << %w{
        taxonID
        relatedTaxonID
        relatedTaxonScientificName
        type
        referenceID
        modified
        modifiedBy
        remarks
      }

      a = biological_association_indices(otus)

      a.find_each(batch_size: 2000) do |bai|
        csv << [
          bai.subject_id,                                                 # taxonID
          nil,                                                            # relatedTaxonID
          bai.object_label,                                               # relatedTaxonScientificName
          bai.relationship_name,                                          # type
          bai.source_id,                                                  # referenceID
          Export::Coldp.modified(bai[:updated_at]),                         # modified
          Export::Coldp.modified_by(bai[:updated_by_id], project_members), # modified_by
          nil                                                             # remarks
        ]
      end

      sources = Source.with(a: ).joins('JOIN a on a.source_id = sources.id')
      Export::Coldp::Files::Reference.add_reference_rows(sources, reference_csv, project_members) if reference_csv

    end
  end
end


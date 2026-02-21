class BulkColdpLifezoneJob < ApplicationJob
  queue_as :coldp_export

  def perform(project_id, otu_id, user_id, value:, overwrite: false)
    Current.user_id = user_id
    Current.project_id = project_id

    lifezone_uri = ::Export::Coldp::Files::Taxon::IRI_MAP[:lifezone]
    predicate = Predicate.where(project_id: project_id, uri: lifezone_uri).first

    unless predicate
      raise TaxonWorks::Error, "Lifezone predicate not found for project #{project_id}. Create it first."
    end

    otu = Otu.where(project_id: project_id).find(otu_id)
    taxon_name_id = otu.taxon_name_id

    return if taxon_name_id.nil?

    otus_in_subtree = Otu.joins(:taxon_name)
      .where(project_id: project_id)
      .where(
        taxon_names: {
          id: TaxonName.descendants_of(
            TaxonName.where(id: taxon_name_id)
          ).select(:id)
        }
      )

    otus_in_subtree.find_each do |subtree_otu|
      existing = InternalAttribute.where(
        attribute_subject: subtree_otu,
        predicate: predicate
      ).first

      if existing
        existing.update!(value: value) if overwrite
      else
        InternalAttribute.create!(
          attribute_subject: subtree_otu,
          predicate: predicate,
          value: value,
          by: user_id,
          project_id: project_id
        )
      end
    end
  end
end

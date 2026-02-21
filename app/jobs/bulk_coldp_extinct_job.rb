class BulkColdpExtinctJob < ApplicationJob
  queue_as :coldp_export

  def perform(project_id, otu_id, user_id, overwrite: false)
    Current.user_id = user_id
    Current.project_id = project_id

    extinct_uri = ::Export::Coldp::Files::Taxon::IRI_MAP[:extinct]
    predicate = Predicate.where(project_id: project_id, uri: extinct_uri).first

    unless predicate
      raise TaxonWorks::Error, "Extinct predicate not found for project #{project_id}. Create it first."
    end

    otu = Otu.where(project_id: project_id).find(otu_id)
    taxon_name_id = otu.taxon_name_id

    return if taxon_name_id.nil?

    # Scope to TaxonNames in the subtree of the root OTU
    subtree_taxon_name_ids = TaxonName
      .joins(:ancestor_hierarchies)
      .where(taxon_name_hierarchies: { ancestor_id: taxon_name_id })
      .select(:id)

    # Find OTUs whose TaxonName has a fossil classification (matching '%fossil' like the rake task)
    otus_in_subtree = Otu
      .where(project_id: project_id)
      .where(
        taxon_name_id: TaxonName.where(id: subtree_taxon_name_ids).where(
          id: TaxonNameClassification.where(
            TaxonNameClassification.arel_table[:type].matches('%Fossil')
          ).select(:taxon_name_id)
        ).select(:id)
      )

    otus_in_subtree.find_each do |fossil_otu|
      existing = InternalAttribute.find_by(
        attribute_subject: fossil_otu,
        predicate: predicate
      )

      if existing
        existing.update!(value: '1') if overwrite
      else
        InternalAttribute.create!(
          attribute_subject: fossil_otu,
          predicate: predicate,
          value: '1',
          by: user_id,
          project_id: project_id
        )
      end
    end
  end
end

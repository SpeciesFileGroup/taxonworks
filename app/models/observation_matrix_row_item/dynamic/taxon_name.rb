# The intent is to capture all OTUs, CollectionObjects (via Determinations), and Extracts (via ancestor_id) linked through a TaxonName Hierarchy
class ObservationMatrixRowItem::Dynamic::TaxonName < ObservationMatrixRowItem::Dynamic

  validate :value_of_observation_object_type
  validate :taxon_name_is_unique

  def observation_objects
    ::Otu.joins(:taxon_name).where(taxon_name: observation_object.self_and_descendants).to_a +
      ::Queries::CollectionObject::Filter.new(ancestor_id: observation_object_id).all.to_a
    # TODO: ON MERGE OF Extract extend with below: Reminder this chains a lot for extracts !!
    #    ::Queries::Extract::Filter.new(ancestor_id: taxon_name_id).all.to_a +
  end

  # @params taxon_name_id required
  # @params otu_id required
  #   Remove all OTU rows for row items attached to this ID or others
  def self.cleanup(taxon_name_id, otu_id)
    to_check = ::TaxonName.find(observation_object_id).self_and_ancestors.pluck(:id)
    self.where(taxon_name_id: to_check).each do |mri|
      mri.update_matrix_rows
    end
  end

  private

  def taxon_name_is_unique
    errors.add(:observation_object, 'is already taken') if ObservationMatrixRowItem::Dynamic::TaxonName.where.not(id: id)
      .where(
        observation_object: observation_object,
        observation_matrix_id: observation_matrix_id,
      ).any?
  end

  def value_of_observation_object_type
    errors.add(:observation_object) if observation_object_type != 'TaxonName'
  end

end

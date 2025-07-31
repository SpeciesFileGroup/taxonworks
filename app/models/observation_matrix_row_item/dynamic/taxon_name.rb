# The intent is to capture all OTUs, CollectionObjects (via Determinations), and Extracts (via taxon_name_id) linked through a TaxonName Hierarchy
class ObservationMatrixRowItem::Dynamic::TaxonName < ObservationMatrixRowItem::Dynamic

  validate :value_of_observation_object_type
  validate :taxon_name_is_unique

  def observation_objects
    a = ::Otu.joins(:taxon_name).where(taxon_name: observation_object.self_and_descendants)
    b = ::Queries::CollectionObject::Filter.new(
      taxon_name_id: observation_object_id,
      descendants: true,
      project_id:).all
    c = ::Queries::Extract::Filter.new(
      taxon_name_id: observation_object_id,
      descendants: true,
      project_id:).all

    if a.count > 10000 or b.count > 10000 or c.count > 10000
      return []
    end

    a.to_a + b.to_a + c.to_a
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
    errors.add(:observation_object, 'is already taken') if ObservationMatrixRowItem::Dynamic::TaxonName.where.not(id:)
      .where(
        observation_object:,
        observation_matrix_id:,
      ).any?
  end

  def value_of_observation_object_type
    errors.add(:observation_object) if observation_object_type != 'TaxonName'
  end

end

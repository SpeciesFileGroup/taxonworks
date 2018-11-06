# A collection object that is classified as being biological in origin.
#
class CollectionObject::BiologicalCollectionObject < CollectionObject
  is_origin_for 'Extract', 'CollectionObject::BiologicalCollectionObject'

  has_many :biocuration_classifications,  inverse_of: :biological_collection_object
  has_many :biocuration_classes, through: :biocuration_classifications, inverse_of: :biological_collection_objects

  # See parent class for comments, this belongs here, but interferes with accepts_nested_attributes
  # has_many :taxon_determinations, inverse_of: :biological_collection_object, dependent: :destroy, foreign_key: :biological_collection_object_id

  accepts_nested_attributes_for :biocuration_classes, allow_destroy: true
  accepts_nested_attributes_for :biocuration_classifications, allow_destroy: true

  has_one :current_taxon_determination, -> {order(:position)}, class_name: 'TaxonDetermination', foreign_key: :biological_collection_object_id, inverse_of: :biological_collection_object
  has_one :current_otu, through: :current_taxon_determination, source: :otu
  has_one :current_taxon_name, through: :current_otu, source: :taxon_name

  soft_validate(:sv_missing_determination, set: :missing_determination)
  soft_validate(:sv_missing_collecting_event, set: :missing_collecting_event)
  soft_validate(:sv_missing_preparation_type, set: :missing_preparation_type)
  soft_validate(:sv_missing_repository, set: :missing_repository)

  def current_taxon_determination=(taxon_determination)
    if taxon_determinations.include?(taxon_determination)
      taxon_determination.move_to_top
    end
  end

  def reorder_determinations_by(attribute = :date)
    determinations = []
    if attribute == :date
      determinations = taxon_determinations.sort{|a, b| b.sort_date <=> a.sort_date }
    else
      determinations = taxon_determinations.order(attribute)
    end

    determinations.each_with_index do |td, i|
      td.position = i + 1
    end

    begin
      TaxonDetermination.transaction do
        determinations.each do |td|
          td.save
        end
      end
    rescue ActiveRecord::RecordInvalid
      return false
    end
    return true
  end

  def sv_missing_determination
    soft_validations.add(:base, 'Determination is missing') if self.reload_current_taxon_determination.nil?
  end

  def sv_missing_collecting_event
    soft_validations.add(:collecting_event_id, 'Collecting event is not selected') if self.collecting_event_id.nil?
  end

  def sv_missing_preparation_type
    soft_validations.add(:preparation_type_id, 'Preparation type is not selected') if self.preparation_type_id.nil?
  end

  def sv_missing_repository
    soft_validations.add(:repository_id, 'Repository is not selected') if self.repository_id.nil?
  end

end

require_dependency 'lot'
require_dependency 'specimen'
require_dependency 'ranged_lot'


# A collection object that is classified as being biological in origin.
#
# !! See also CollectionObject::BiologicalExtensions
class CollectionObject::BiologicalCollectionObject < CollectionObject
    
  # !! See also CollectionObject::BiologicalExtensions, all code there technically belongs here

  has_many :biocuration_classifications,  inverse_of: :biological_collection_object, dependent: :destroy
  has_many :biocuration_classes, through: :biocuration_classifications, inverse_of: :biological_collection_objects

  accepts_nested_attributes_for :biocuration_classes, allow_destroy: true
  accepts_nested_attributes_for :biocuration_classifications, allow_destroy: true

  soft_validate(:sv_missing_determination,
                set: :missing_determination,
                name: 'Missing determination',
                description: 'Determination is missing')

  soft_validate(:sv_missing_collecting_event,
                set: :missing_collecting_event,
                name: 'Missing collecting event',
                description: 'Missing collecting event')

  soft_validate(:sv_missing_preparation_type,
                set: :missing_preparation_type,
                name: 'Missing preparation type',
                description: 'Missing preparation type')

  soft_validate(:sv_missing_repository,
                set: :missing_repository,
                name: 'Missing repository',
                description: 'Repository is not selected')

  soft_validate(:sv_missing_biocuration_classification,
                set: :missing_biocuration_classification,
                name: 'Missing biocuration classification',
                description: 'Biocuration classification is not indicated')

  def current_taxon_determination=(taxon_determination)
    if taxon_determinations.include?(taxon_determination)
      taxon_determination.move_to_top
    end
  end

  # @return [Boolean]
  #   nil values are sent to the bottom
  def reorder_determinations_by(attribute = :date)
    determinations = []
    if attribute == :date
      determinations = taxon_determinations.sort{|a, b| (b.sort_date || Time.utc(1, 1))  <=> (a.sort_date || Time.utc(1,1)) }
    else
      determinations = taxon_determinations.order(attribute)
    end

    begin
      TaxonDetermination.transaction do
        determinations.each_with_index do |td, i|
          td.update_column(:position, i + 1)
        end
      end
    rescue
      return false
    end
    return true
  end

  protected 

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

  def sv_missing_biocuration_classification
    soft_validations.add(:repository_id, 'Biocuration is not specified') unless self.biocuration_classifications.any?
  end

end

require_dependency 'lot'
require_dependency 'specimen'
require_dependency 'ranged_lot'


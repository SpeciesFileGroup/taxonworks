class CollectionObject::BiologicalCollectionObject < CollectionObject
  has_many :biocuration_classifications,  inverse_of: :biological_collection_object
  has_many :biocuration_classes, through: :biocuration_classifications, inverse_of: :biological_collection_objects
  
  has_many :otus, through: :taxon_determinations, inverse_of: :taxon_determinations
  has_many :taxon_determinations, inverse_of: :biological_collection_object
 
  accepts_nested_attributes_for :biocuration_classes, :biocuration_classifications, :taxon_determinations, :otus

  soft_validate(:sv_missing_determination, set: :missing_determination)
  soft_validate(:sv_missing_collecting_event, set: :missing_collecting_event)
  soft_validate(:sv_missing_preparation_type, set: :missing_preparation_type)
  soft_validate(:sv_missing_repository, set: :missing_repository)

  # @return [TaxonDetermination, nil]
  #    the last added taxon determination
  def current_determination
    taxon_determinations.sort_by{|i| i.position}.last
  end

  def reorder_determinations_by(attribute = :date)
    determinations = []
    if attribute == :date
      determinations = taxon_determinations.sort{|a, b| a.sort_date <=> b.sort_date }
    else
      determinations = taxon_determinations.order(attribute)
    end

    determinations.each_with_index do |td, i|
      td.update(position: i+1)
    end

    begin
      TaxonDetermination.transaction do
        determinations.each do |td|
          td.save
        end
      end
    rescue
      return false
    end
    return true
  end

  def sv_missing_determination
    soft_validations.add(:base, 'Determination is missing') if self.current_determination.nil?
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



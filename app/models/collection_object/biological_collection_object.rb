class CollectionObject::BiologicalCollectionObject < CollectionObject
  has_many :biocuration_classes, through: :biocuration_classifications, inverse_of: :biological_collection_objects
  has_many :biocuration_classifications,  inverse_of: :biological_collection_object
  has_many :otus, through: :taxon_determinations
  has_many :taxon_determinations, inverse_of: :biological_collection_object
 
  accepts_nested_attributes_for :biocuration_classes, :biocuration_classifications, :taxon_determinations, :otus

  before_validation :reassign_type_if_total_provided

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

  protected

  def reassign_type_if_total_provided
    return true if !self.ranged_lot_category_id.nil? || self.total.nil?
    if self.total == 1
      self.type = 'Specimen'
    elsif self.total > 1
      self.type = 'Lot'
    end
  end

end

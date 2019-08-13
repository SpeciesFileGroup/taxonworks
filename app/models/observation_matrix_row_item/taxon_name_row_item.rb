
# The intent is to capture all OTUs linked through a TaxonName Hierarchy
class ObservationMatrixRowItem::TaxonNameRowItem < ObservationMatrixRowItem

  belongs_to :taxon_name

  validates_presence_of :taxon_name_id
  validates_uniqueness_of :taxon_name_id, scope: [:observation_matrix_id]

  def self.subclass_attributes
    [:taxon_name_id]
  end

  def otus
    Otu.joins(:taxon_name).where(taxon_name: taxon_name.self_and_descendants)
  end

  def collection_objects
    CollectionObject.none
  end

  def matrix_row_item_object
    taxon_name 
  end

  def is_dynamic?
    true
  end

end

class ObservationMatrixRowItem::SingleCollectionObject < ObservationMatrixRowItem

  belongs_to :collection_object

  validates_presence_of :collection_object
  validates_uniqueness_of :collection_object_id, scope: [:observation_matrix_id]

  def self.subclass_attributes
    [:collection_object_id]
  end

  def collection_objects
    [self.collection_object]
  end

  def matrix_row_item_object
    collection_object
  end

end

class ObservationMatrixRowItem::Single::CollectionObject < ObservationMatrixRowItem::Single

  belongs_to :collection_object, inverse_of: :observation_matrix_row_items, class_name: '::CollectionObject'

  validates_presence_of :collection_object
  validates_uniqueness_of :collection_object_id, scope: [:observation_matrix_id]

  def self.subclass_attributes
    [:collection_object_id]
  end

  def collection_objects
    [collection_object].compact
  end

  def matrix_row_item_object
    collection_object
  end

end

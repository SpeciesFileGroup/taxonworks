class MatrixRowItem::SingleCollectionObject < MatrixRowItem

  belongs_to :collection_object

  validates_presence_of :collection_object_id
  validates_uniqueness_of :collection_object_id, scope: [:matrix_id]

  def self.subclass_attributes
    [:collection_object_id]
  end

  def collection_objects
    [self.collection_object]
  end
end
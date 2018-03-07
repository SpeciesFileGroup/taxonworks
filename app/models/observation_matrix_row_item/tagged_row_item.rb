class ObservationMatrixRowItem::TaggedRowItem < ObservationMatrixRowItem

  belongs_to :controlled_vocabulary_term

  validates_presence_of :controlled_vocabulary_term_id
  validates_uniqueness_of :controlled_vocabulary_term_id, scope: [:observation_matrix_id]

  def self.subclass_attributes
    [:controlled_vocabulary_term_id]
  end

  def otus
    Tag.where(keyword: controlled_vocabulary_term, tag_object_type: 'Otu').map(&:tag_object)
  end

  def collection_objects
    Tag.where(keyword: controlled_vocabulary_term, tag_object_type: 'CollectionObject').map(&:tag_object)
  end

  def matrix_row_item_object
    controlled_vocabulary_term 
  end

end

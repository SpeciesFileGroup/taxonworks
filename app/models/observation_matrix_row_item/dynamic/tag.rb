class ObservationMatrixRowItem::Dynamic::Tag < ObservationMatrixRowItem::Dynamic

  belongs_to :controlled_vocabulary_term, inverse_of: :observation_matrix_column_items, class_name: '::ControlledVocabularyTerm'

  validates_presence_of :controlled_vocabulary_term_id
  validates_uniqueness_of :controlled_vocabulary_term_id, scope: [:observation_matrix_id]

  def self.subclass_attributes
    [:controlled_vocabulary_term_id]
  end

  def otus
    Otu.joins(:tags).where(tags: {keyword: controlled_vocabulary_term})
  end

  def collection_objects
    CollectionObject.joins(:tags).where(tags: {keyword: controlled_vocabulary_term})
  end

  def matrix_row_item_object
    controlled_vocabulary_term 
  end

end

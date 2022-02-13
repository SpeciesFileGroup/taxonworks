class ObservationMatrixRowItem::Dynamic::Tag < ObservationMatrixRowItem::Dynamic

  belongs_to :controlled_vocabulary_term, inverse_of: :observation_matrix_column_items, class_name: '::ControlledVocabularyTerm'

  validates_presence_of :controlled_vocabulary_term_id
  validates_uniqueness_of :controlled_vocabulary_term_id, scope: [:observation_matrix_id]

  def self.subclass_attributes
    [:controlled_vocabulary_term_id]
  end

  # TODO: make this dynamic based on classes that are Observable!
  def row_objects
    Otu.joins(:tags).where(tags: {keyword: controlled_vocabulary_term}).to_a +
      CollectionObject.joins(:tags).where(tags: {keyword: controlled_vocabulary_term}).to_a
    # +
    #  Extract.joins(:tags).where(tags: {keyword: controlled_vocabulary_term}).to_a
  end

  def matrix_row_item_object
    controlled_vocabulary_term
  end

end

class ObservationMatrixRowItem::Dynamic::Tag < ObservationMatrixRowItem::Dynamic

  belongs_to :controlled_vocabulary_term, inverse_of: :observation_matrix_column_items, class_name: '::ControlledVocabularyTerm'

  validates_presence_of :controlled_vocabulary_term_id
  validates_uniqueness_of :controlled_vocabulary_term_id, scope: [:observation_matrix_id]

  def self.subclass_attributes
    [:controlled_vocabulary_term_id]
  end

  def observation_objects
    d = []
    OBSERVABLE_TYPES.each do |t| # Currently assumes all types are also taggable, could do a simple check
      d += t.safe_constantize.joins(:tags).where(tags: {keyword: controlled_vocabulary_term}).to_a 
    end
    d
  end

  def matrix_row_item_object
    controlled_vocabulary_term
  end

end

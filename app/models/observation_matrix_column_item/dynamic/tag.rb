# Adds columns to matrix for descriptors tagged with the Keyword
# 
class ObservationMatrixColumnItem::Dynamic::Tag < ObservationMatrixColumnItem::Dynamic

  belongs_to :controlled_vocabulary_term, inverse_of: :observation_matrix_column_items, class_name: '::ControlledVocabularyTerm'

  validates_presence_of :controlled_vocabulary_term_id
  validates_uniqueness_of :controlled_vocabulary_term_id, scope: [:observation_matrix_id]

  def self.subclass_attributes
    [:controlled_vocabulary_term_id]
  end

  def descriptors
    Descriptor.joins(:tags).where(tags: {keyword: controlled_vocabulary_term}).to_a
  end

end


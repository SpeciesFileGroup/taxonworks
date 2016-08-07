# Adds columns to matrix for descriptors tagged with the provide Keyword (ControlledVocabularyTerm)
# 
class MatrixColumnItem::TaggedDescriptor < MatrixColumnItem 

  belongs_to :controlled_vocabulary_term

  validates_presence_of :controlled_vocabulary_term_id
  validates_uniqueness_of :controlled_vocabulary_term_id, scope: [:matrix_id]

  def self.subclass_attributes
    [:controlled_vocabulary_term_id]
  end

  def descriptors
    Tag.where(keyword: controlled_vocabulary_term, tag_object_type: 'Descriptor').map(&:tag_object)
  end

end


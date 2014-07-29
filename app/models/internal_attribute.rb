class InternalAttribute < DataAttribute 
  include Housekeeping
  belongs_to :predicate, foreign_key: :controlled_vocabulary_term_id, inverse_of: :internal_attributes
  validates :predicate, presence: true
end

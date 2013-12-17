class DataAttribute::InternalAttribute < DataAttribute 
  include Housekeeping
  belongs_to :predicate, foreign_key: :controlled_vocabulary_term_id
  validates :predicate, presence: true
end

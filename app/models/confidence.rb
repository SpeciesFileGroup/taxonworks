class Confidence < ActiveRecord::Base
  include Housekeeping
  include Shared::IsData

  acts_as_list scope: [:confidence_level_id]

  belongs_to :confidence_level
  belongs_to :confidence_object, polymorphic: true

  belongs_to :controlled_vocabulary_term, foreign_key: :confidence_level_id

  validates_presence_of :confidence_id

  validates_uniqueness_of :confidence_level_id, scope: [:confidence_object_id, :confidence_object_type]
end

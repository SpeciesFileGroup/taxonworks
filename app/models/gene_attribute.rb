class GeneAttribute < ActiveRecord::Base
  include Housekeeping
  include Shared::Identifiable
  include Shared::IsData
  include Shared::Notable
  include Shared::Taggable

  belongs_to :descriptor
  belongs_to :sequence
  belongs_to :controlled_vocabulary_term
  belongs_to :project

  validates_presence_of :descriptor_id
  validates_presence_of :sequence_id
  
end

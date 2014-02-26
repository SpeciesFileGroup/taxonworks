class ControlledVocabularyTerm < ActiveRecord::Base
  include Housekeeping
  include Shared::AlternateValues

  validates_presence_of :name, :definition, :type
  validates_length_of :definition, minimum: 4

  validates_uniqueness_of :name, scope: [:type, :project_id]
  validates_uniqueness_of :definition, scope: [:project_id]
end

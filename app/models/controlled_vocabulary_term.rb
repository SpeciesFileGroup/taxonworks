class ControlledVocabularyTerm < ActiveRecord::Base
  include Housekeeping
  include Shared::IsData 
  include Shared::AlternateValues
  # include Shared::Taggable <- !! NO

  validates_presence_of :name, :definition, :type
  validates_length_of :definition, minimum: 4

  validates_uniqueness_of :name, scope: [:type, :project_id]
  validates_uniqueness_of :definition, scope: [:project_id]
  validates_uniqueness_of :same_as_uri, scope: [:project_id], allow_nil: true

  # TODO: @mjy What *is* the right construct for 'ControlledVocabularyTerm'?
  def self.find_for_autocomplete(params)
    where('name LIKE ?', "#{params[:term]}%")
  end

end

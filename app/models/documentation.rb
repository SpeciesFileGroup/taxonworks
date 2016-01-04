class Documentation < ActiveRecord::Base
  include Housekeeping
  include Shared::Identifiable
  include Shared::Notable
  include Shared::Taggable
  include Shared::IsData
  include SoftValidation

  belongs_to :documentation_object, polymorphic: true
  belongs_to :document

  validates_presence_of :documentation_object_type, :documentation_object_id, :document_id

  def self.find_for_autocomplete(params)
    Queries::DocumentationAutocompleteQuery.new(params[:term]).all.where(project_id: params[:project_id])
  end


end

class Documentation < ActiveRecord::Base
  include Housekeeping
  include Shared::Identifiable
  include Shared::Notable
  include Shared::Taggable
  include Shared::IsData
  include SoftValidation

  belongs_to :documentation_object, polymorphic: true
  belongs_to :document

  #region class methods

  def self.find_for_autocomplete(params)
    Queries::DocumentationAutocompleteQuery.new(params[:term]).all.where(project_id: params[:project_id])
  end

  #endregion

end

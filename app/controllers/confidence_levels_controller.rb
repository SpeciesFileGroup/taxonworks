class ConfidenceLevelsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  def lookup
    @confidence_levels = Queries::ControlledVocabularyTermAutocompleteQuery.new(term_param, project_id: sessions_current_project_id, object_type: 'ConfidenceLevel').all
    render(:json => @confidence_levels.collect { |t|
      {
          label: t.name,
          object_id: t.id,
          definition: t.definition
      }
    })
  end

  protected

  def term_param
    params.require(:term)
  end

end

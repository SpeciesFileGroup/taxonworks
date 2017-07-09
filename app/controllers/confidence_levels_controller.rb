class ConfidenceLevelsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration


  # GET /index.json
  def index
    respond_to do |format|

      format.html do
        render '/shared/data/all/index' 
      end

      format.json do
        @controlled_vocabulary_terms = ConfidenceLevel.with_project_id(sessions_current_project_id).order(:position)
        render '/controlled_vocabulary_terms/index' 
      end
    end
  end

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

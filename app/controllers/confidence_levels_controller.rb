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

  def autocomplete
    confidence_levels = ConfidenceLevel.find_for_autocomplete(params.merge(project_id: sessions_current_project_id)).distinct

    data = confidence_levels.collect do |t|
      str = t.name + ': ' + t.definition
      {id: t.id,
       label: str,
       response_values: {
         params[:method] => t.id},
       label_html: str
      }
    end

    render json: data
  end

  def lookup
    @confidence_levels = Queries::ControlledVocabularyTermAutocompleteQuery.new(term_param, project_id: sessions_current_project_id, object_type: ['ConfidenceLevel']).all
    render(json: @confidence_levels.collect { |t|
      {
        label: t.name,
        object_id: t.id,
        definition: t.definition
      }
    })
  end

  def select_options
    @confidence_levels = ConfidenceLevel.select_optimized(sessions_current_user_id, sessions_current_project_id, params.require(:klass))
  end

  protected

  def term_param
    params.require(:term)
  end

end

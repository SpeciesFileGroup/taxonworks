class PredicatesController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  def autocomplete
    predicates = Queries::ControlledVocabularyTerm::Autocomplete.new(params[:term], project_id: sessions_current_project_id, of_type: ['Predicate']).autocomplete

    data = predicates.collect do |t|
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

  # GET /predicates/select_options?klass=CollectionObject
  def select_options
    @predicates = Predicate.select_optimized(sessions_current_user_id, sessions_current_project_id, params.require(:klass))
  end

end

class KeywordsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  def autocomplete
    predicates = Keyword.find_for_autocomplete(params.merge(project_id: sessions_current_project_id)).uniq

    data = predicates.collect do |t|
      str = t.name + ": " + t.definition
      {id: t.id,
       label: str,
       response_values: {
         params[:method] => t.id},
       label_html: str
      }
    end

    render :json => data
  end

end

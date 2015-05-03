class TopicsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  def autocomplete
    predicates = Topic.find_for_autocomplete(params.merge(project_id: sessions_current_project_id))

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

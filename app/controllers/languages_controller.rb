class LanguagesController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  # GET /languages/select_options?klass=source|serial
  def select_options
    @languages = Language.select_optimized(sessions_current_user_id, sessions_current_project_id, params.require(:klass))
  end

  def autocomplete
    languages = Language.find_for_autocomplete(params)

    data = languages.collect do |t|
      str = t.english_name 
      {id: t.id,
       label: str,
       response_values: {
         params[:method] => t.id},
       label_html: str
      }
    end

    render json: data
  end

end

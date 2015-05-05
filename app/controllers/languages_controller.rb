class LanguagesController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

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

    render :json => data
  end

end

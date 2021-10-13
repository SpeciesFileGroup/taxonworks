class KeywordsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  def select_options
    @keywords = Keyword.select_optimized(sessions_current_user_id, sessions_current_project_id, params.require(:klass))
  end

end

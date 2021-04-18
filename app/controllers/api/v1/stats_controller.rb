class Api::V1::StatsController < ApiController 

  def index
    if params[:project_token]
      @project_id = Project.find_by_api_access_token(params[:project_token]).id
    end
  end

end

class Api::V1::StatsController < ApiController 

  def index
    if params[:project_token]
      project = Project.find_by_api_access_token(params[:project_token])
      if project
        @project_id = project.id
      else
        render file: "#{Rails.root}/public/404.html", layout: false, status: :not_found
      end
    end
  end
 
  # Keeping all project endpoints out of projects for now
  # /api/v1/activity?project_token= 
  def activity
    if params[:project_token]
      @project = Project.find_by_api_access_token(params[:project_token])
      if @project
        render '/projects/api/v1/activity'
      else
        render file: "#{Rails.root}/public/404.html", layout: false, status: :not_found
      end
    end
  end

end

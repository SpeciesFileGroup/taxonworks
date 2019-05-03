# Methods for token authentication.
#
# Do no add controller callbacks here, the methods need
# to apply to both "internal" and `/api/v<n>` routes.
module TokenAuthentication 
  extend ActiveSupport::Concern

  def token_authenticate
    t = params[:token]

    unless t
      authenticate_with_http_token do |token, _options|
        t = token
      end
    end
    
    @sessions_current_user = User.find_by_api_access_token(t) if t
  end

  def intercept_user
    if not token_authenticate
      render(json: {success: false}, status: :unauthorized) && return
    end
    true
  end

  def project_token_authenticate
    t = params[:project_token]
    h = request.headers['Project token']

    unless t
      t = h
    end

    @sessions_current_project = Project.find_by_api_access_token(t) if t

    if @sessions_current_project
      # check for agreement between provided values 
      return false if params[:project_id] && @sessions_current_project.id != params[:project_id]&.to_i
      return false if request.headers['project_id'] && @sessions_current_project.id != request.headers['project_id']&.to_i

      @sessions_current_project
    else
      false
    end
  end

  def intercept_project
    if not project_token_authenticate
      render(json: {success: false}, status: :unauthorized) && return
    end
    true
  end
end

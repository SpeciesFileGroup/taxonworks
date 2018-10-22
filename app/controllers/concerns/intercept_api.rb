module InterceptApi 
  extend ActiveSupport::Concern

  included do
    before_action :intercept_api
  end

  def token_authenticate
    t = params[:token]

    unless t
      authenticate_with_http_token do |token, _options|
        t = token
      end
    end

    @sessions_current_user = User.find_by_api_access_token(t) if t
  end

  # TODO: Fix in API issues
  def intercept_api
    if /^\/api/ =~ request.path
      if token_authenticate
        render(json: {success: false}, status: :bad_request) && return unless set_project_from_params
      else
        render(json: {success: false}, status: :unauthorized) && return
      end
    end

    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'

    true
  end
end

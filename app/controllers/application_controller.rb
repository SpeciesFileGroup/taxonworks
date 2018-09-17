# this is the main controller
require_dependency 'lib/application_enumeration.rb'
class ApplicationController < ActionController::Base
  include Workbench::SessionsHelper
  include ProjectsHelper

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  rescue_from ActionController::ParameterMissing do |exception|
    raise unless request.format == :json
    render json: { error: exception }, status: 400
  end

  attr_writer :is_data_controller, :is_task_controller

  # Potentially used
  attr_writer :meta_title, :meta_data, :site_name
  attr_accessor :meta_description, :meta_keywords, :page_title

  helper_method :is_data_controller?, :is_task_controller?

  # Potentially used.
  helper_method :meta_title, :meta_data, :site_name, :page_title

  before_action :intercept_api
  before_action :set_project_and_user_variables
  before_action :notice_user

  after_action :log_user_recent_route
  after_action :clear_project_and_user_variables

  def intercept_api
    if /^\/api/ =~ request.path # rubocop:disable Style/RegexpLiteral
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

  # TODO: Make RecenRoutes modules that handles exceptions, only etc.
  def log_user_recent_route
    sessions_current_user.add_recently_visited_to_footprint(request.fullpath, @recent_object) if sessions_current_user
  end

  def set_project_and_user_variables
    $project_id = sessions_current_project_id # This also sets @sessions_current_project_id
    $user_id    = sessions_current_user_id
  end

  def clear_project_and_user_variables
    $project_id = nil
    $user_id    = nil
  end

  # Returns true if the controller is that of data class. See controllers/concerns/data_controller_configuration/ concern.
  # Data controllers can not be task controllers.
  def is_data_controller?
    @is_data_controller
  end

  # Returns true if the controller is a task controller. See controllers/concerns/task_controller_configuration/ concern.
  # Task controllers can not be data controllers.
  def is_task_controller?
    @is_task_controller
  end

  def meta_title
    @meta_title ||= [@meta_title.presence || @page_title.presence, site_name].compact.join(' | ')
  end

  def meta_data
    @meta_data ||= {
      description: @meta_description,
      keywords: @meta_keywords
    }.delete_if { |_k, v| v.nil? }
  end

  def site_name
    @site_name ||= 'TaxonWorks'
  end

  def digest_cookie(file, key)
    sha256 = Digest::SHA256.file(file)
    cookies[key] = sha256.hexdigest
  end

  def digested_cookie_exists?(file, key)
    sha256 = Digest::SHA256.file(file)
    cookies[key] == sha256.hexdigest
  end

  private

  def notice_user
    if sessions_current_user
      sessions_current_user.update_last_seen_at
    end
  end

  def record_not_found
    respond_to do |format|
      format.html { render plain: '404 Not Found', status: 404 }
      format.json { render json: {success: false}, status: 404 }
    end
  end

  def disable_turbolinks
    @no_turbolinks = true
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

  def set_project_from_params
    self.sessions_current_project_id = params[:project_id]
  end

  def invalid_object(object)
    !(!object.try(:project_id) || project_matches(object))
  end

  def project_matches(object)
    object.try(:project_id) == sessions_current_project_id
  end

  # @param klass_name [String] a model name inheriting from IsData
  def whitelist_constantize(klass_name)
    if Rails.env.development?
      ApplicationEnumeration.data_models.inject({}){|hsh, k| hsh.merge!(k.name => k)}.fetch(klass_name)
    elsif Rails.env.production?
      ::DATA_MODELS.fetch(klass_name)
    else
      raise TaxonWorks::Error, 'whitelist attempted in unknown environment'
    end
  end
end

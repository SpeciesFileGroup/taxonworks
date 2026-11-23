# Authenticates Mobile app POSTs to a Task with a task_token (see
# lib/task_token). Parallel to, and independent of, TokenAuthentication
# and Api::*; this is not /api/v1.
#
# Included in ApplicationController so that a token is refused on every
# route that is not a token route. Task controllers declare their token
# actions, e.g.:
#
#   include TaskTokenAuthentication
#   task_token_origin :quick_mobile_material_task
#   task_token_actions :capture
#   task_token_lifetime 2.hours
#
# Token actions:
# * are reachable only from routes in config/routes/task_token.rb
# * read the token from the X-Task-Token header ONLY (a task_token param is a 400)
# * never read the session, Current is set here (and only here) once every check passes
# * handle initiation (a pending token) here: the action itself only ever
#   sees an active token
#
# Claude Code (Opus 5.5) wrote > 50% of this module.
#
module TaskTokenAuthentication
  extend ActiveSupport::Concern

  HEADER = 'X-Task-Token'.freeze

  # Param name, never accepted, see #task_token_param?
  PARAM = 'task_token'.freeze

  included do
    class_attribute :task_token_action_names, default: [].freeze, instance_writer: false
    class_attribute :task_token_origin_name, default: nil, instance_writer: false
    class_attribute :task_token_lifetime_value, default: TaskToken::DEFAULT_LIFETIME, instance_writer: false

    prepend_before_action :refuse_misplaced_task_token
  end

  class_methods do
    # @param origin [Symbol, String] the Task route name
    def task_token_origin(origin)
      self.task_token_origin_name = origin.to_s
    end

    # @param lifetime [ActiveSupport::Duration] of an active token, fixed at activation
    def task_token_lifetime(lifetime)
      raise ArgumentError, "task_token_lifetime may not exceed #{TaskToken::MAXIMUM_LIFETIME.inspect}" if lifetime > TaskToken::MAXIMUM_LIFETIME
      self.task_token_lifetime_value = lifetime
    end

    # Registers token authentication for only these actions, and skips the
    # session callbacks for them.
    def task_token_actions(*actions)
      actions = actions.map(&:to_s)
      self.task_token_action_names = (task_token_action_names + actions).freeze

      skip_before_action :require_sign_in_and_project_selection, only: actions, raise: false
      skip_before_action :set_housekeeping, only: actions
      skip_before_action :notice_user, only: actions
      skip_before_action :set_exception_notification_data, only: actions
      skip_forgery_protection only: actions

      before_action :authenticate_task_token, only: actions
    end
  end

  protected

  # @return [Hash, nil] the verified token payload, token actions only
  def task_token_payload
    @task_token_payload
  end

  # @return [Hash] the token's named attributes, e.g. composition_id
  def task_token_attributes
    task_token_payload&.fetch('attributes', {}) || {}
  end

  # Session actions only (the User is signed in to TaxonWorks).
  # @return [TaskToken::Issued]
  def issue_task_token(attributes: {})
    TaskToken.issue(user_id: Current.user_id, project_id: Current.project_id, origin: task_token_origin_name, attributes:)
  end

  # Session actions only.
  def invalidate_task_token
    TaskToken.invalidate(user_id: Current.user_id, origin: task_token_origin_name)
  end

  # Session actions only.
  # @return [Hash, nil] see TaskToken.status
  def task_token_status
    TaskToken.status(user_id: Current.user_id, origin: task_token_origin_name)
  end

  private

  def task_token_action?
    task_token_action_names.include?(action_name)
  end

  # True only for routes drawn in config/routes/task_token.rb.
  def task_token_route?
    request.path_parameters[:task_token_route] == true
  end

  # True if the request path is under the origin Task's own path.
  def task_token_route_in_origin?
    return false if task_token_origin_name.blank?
    origin_path = Rails.application.routes.url_helpers.public_send("#{task_token_origin_name}_path")
    request.path.start_with?(origin_path.chomp('/') + '/')
  end

  def task_token_param?
    request.query_parameters.key?(PARAM) || request.request_parameters.key?(PARAM)
  end

  # A token is accepted ONLY by token actions on token routes.
  def refuse_misplaced_task_token
    return if task_token_action? && task_token_route?

    if request.headers[HEADER].present? || task_token_route?
      render_task_token_failure(:unauthorized, 'task_token is not accepted here')
    end
  end

  def authenticate_task_token
    return render_task_token_failure(:bad_request, 'task_token is accepted only in the X-Task-Token header') if task_token_param?
    return render_task_token_failure(:unauthorized) unless task_token_route? && task_token_route_in_origin?

    result = TaskToken.verify(request.headers[HEADER], origin: task_token_origin_name)

    return render_task_token_failure(:too_many_requests, 'too many requests, task_token invalidated') if result.status == :too_many_requests
    return render_task_token_failure(:unauthorized) unless result.ok?

    payload = result.payload
    sent_ids = request.request_parameters.merge(request.query_parameters)

    return render_task_token_failure(:unauthorized) unless TaskToken.ids_match?(payload, sent_ids) && TaskToken.live?(payload)

    if result.stage == :initiation
      activated = TaskToken.activate(payload, lifetime: task_token_lifetime_value)
      return render_task_token_failure(:unauthorized, 'task_token already activated') if activated.nil?
      return render json: { task_token: activated.token, expires_at: activated.expires_at.utc.iso8601 }, status: :ok
    end

    @task_token_payload = payload
    Current.user_id = payload['user_id']
    Current.project_id = payload['project_id']

    request.env['exception_notifier.exception_data'] = {
      user: { user_id: payload['user_id'] },
      project: { project_id: payload['project_id'] },
      task_token: { origin: payload['origin'] }
    }
  end

  def render_task_token_failure(status, message = 'task_token invalid')
    render json: { errors: [message] }, status:
  end

end

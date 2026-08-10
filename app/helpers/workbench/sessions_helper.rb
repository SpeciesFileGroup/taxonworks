# These are used in both controllers and views.
module Workbench::SessionsHelper

  # User methods
  def sessions_signed_in?
    !sessions_current_user.nil?
  end

  def sessions_current_user=(user)
    @sessions_current_user = user
  end

  def sessions_current_user
    @sessions_current_user ||= User.find_by(remember_token: User.encrypt(cookies[:remember_token]))
  end

  # TODO: Move to co its own concern in /vendor
  # Papertrail
  alias_method :current_user, :sessions_current_user

  def sessions_current_user_id
    sessions_current_user ? sessions_current_user.id : nil
  end

  def sessions_sign_in(user, request)
    remember_token = User.secure_random_token
    cookies.permanent[:remember_token] = remember_token

    c = {
      remember_token: User.encrypt(remember_token),
      sign_in_count: (user.sign_in_count + 1),
      last_sign_in_at: user.current_sign_in_at,
      current_sign_in_at: Time.now,
      last_sign_in_ip: user.current_sign_in_ip,
      current_sign_in_ip: request.ip,
    }

    # TODO set to zero on User create to eliminate need for this
    c[:time_active] = 0 if user.time_active.blank?

    user.update_columns( c )

    self.sessions_current_user = user
  end

  def sessions_sign_out
    self.sessions_current_user = nil
    sessions_clear_selected_project
    cookies.delete(:remember_token)
  end

  # Project methods

  def set_project_from_params
    # Ensure project_token and project_id are the same if provided.
    # TODO: Community data considerations
    if sessions_current_project_id
      respond_to do |format|
        format.html { redirect_to root_url, notice: 'Project token and project are not the same.'  }
        format.json { render(json: {success: false}, status: :bad_request) && return } # was unauthorized
      end
    else
      self.sessions_current_project_id = params[:project_id] if ProjectMember.exists?(project_id: params[:project_id], user_id: sessions_current_user_id)
    end
  end

  def sessions_project_selected?
    !sessions_current_project_id.nil?
  end

  def sessions_current_project_id=(project_id)
    if @api_request
      @sessions_current_project = Project.find(project_id)
    else
      session[:project_id] = project_id
    end
    project_id
  end

  def sessions_current_project_id
    if @api_request
      return @sessions_current_project.id if @sessions_current_project
    else
      session[:project_id]
    end
  end

  def sessions_current_project
    return nil unless sessions_current_project_id

    if @sessions_current_project.nil? || @sessions_current_project.id != sessions_current_project_id
      @sessions_current_project = Project.find_by(id: sessions_current_project_id)
    end
      @sessions_current_project
  end

  def sessions_select_project(project)
    self.sessions_current_project_id = project.id
   sessions_current_project
  end

  def sessions_clear_selected_project
    if @api_request
      @sessions_current_project = nil
    else
      session[:project_id] = nil
    end
  end

  # Authorization methods
  def is_administrator?
    sessions_signed_in? && sessions_current_user.is_administrator?
  end

  # Can be optimized to just look at ProjectMembers likely
  def is_project_administrator?
    sessions_signed_in? && sessions_project_selected? &&
    sessions_current_project&.project_members&.exists?(is_project_administrator: true, user_id: sessions_current_user_id)
  end

  def administers_projects?
    sessions_signed_in? && (is_administrator? || sessions_current_user.administers_projects? )
  end

  # A superuser is an administrator or a person who is a project_administrator IN THE CURRENTLY SELECTED PROJECT
  def is_superuser?
    sessions_signed_in? && ( is_administrator? || is_project_administrator? )
  end

  def is_project_member?(user, project)
    project.project_members.exists?(user:)
  end

  def is_project_member_by_id?(user_id, project_id)
    ProjectMember.exists?(user_id:, project_id:)
  end

  def authorize_project_selection(user, project)
    project.project_members.exists?(user:)
  end

  def require_sign_in
    redirect_to root_url, notice: 'Please sign in.' unless sessions_signed_in?
  end

  def require_project_selection
    redirect_to root_url, notice: 'Please select a project.' unless sessions_current_project
  end

  def require_sign_in_and_project_selection
    # TODO: account for permitted token based projects
    unless (sessions_signed_in? or @api_request) && sessions_project_selected?
      respond_to do |format|
        format.html { redirect_to root_url, notice: 'Whoa there, sign in and select a project first.'  }
        format.json { render json: { error: 'Whoa there, sign in and select a project first.' }, status: :unauthorized } # TODO: bad request, not unauthorized
      end
    end
  end

  def require_administrator_sign_in
    redirect_to root_url, notice: 'Please sign in as an administrator.' unless is_administrator?
  end

  def require_project_administrator_sign_in
    redirect_to root_url, notice: 'Please sign in as a project administrator.' unless is_project_administrator?
  end

  def require_superuser_sign_in
    redirect_to root_url, notice: 'Please sign in as a project administrator or administrator.' unless is_superuser?
  end

  # User is some project_administrator or administrator
  def can_administer_projects?
    redirect_to root_url, notice: 'Please sign in as a project administrator or administrator.' unless administers_projects?
  end

  # TODO: make this a non-controller method
  def session_header_links
    [
      header_menu_link('Dashboard', root_path, 'layout-dashboard'),
      content_tag(:div, '', id: 'vue-pinboard-navigator'),
      project_settings_link,
      issue_tracker_tag
    ]
  end

  # @return [String]
  #   a link with a leading icon, as used in the header dropdown menus
  def header_menu_link(label, path, icon_name, **options)
    link_to(path, options) do
      safe_join([icon(icon_name), content_tag(:span, label)])
    end
  end

  def session_user_header_links
    [
      header_menu_link('Account', sessions_current_user, 'user', data: {
        current_user_id: sessions_current_user.id.to_s,
        current_user_is_administrator: sessions_current_user.is_administrator,
      }),
      header_menu_link('Sign out', signout_path, 'log-out', method: :delete, id: 'sign_out')
    ]
  end

  def favorite_star_icon(filled:)
    icon('favorite-star', fill: filled ? 'currentColor' : 'none')
  end

  def favorite_page_link(kind, name)
    if favorites?(kind, name)
      link_to(favorite_star_icon(filled: true), unfavorite_page_path(kind:, name:), method: :post, remote: true, id: "unfavorite_link_#{kind}-#{name}", class: :unfavorite_link, 'aria-label': 'Remove from favorites', 'data-tooltip-content': 'Remove from favorites')
    else
      link_to(favorite_star_icon(filled: false), favorite_page_path(kind:, name:), method: :post, remote: true, id: "favorite_link_#{kind}-#{name}", class: :favourite_link, 'aria-label': 'Add to favorites', 'data-tooltip-content': 'Add to favorites')
    end
  end

  def has_hub_favorites?
    sessions_current_user.hub_favorites[sessions_current_project_id.to_s] ? true : false
  end

  # @param [String]
  # @param [String]
  def favorites?(kind, name)
    has_hub_favorites? && sessions_current_user.hub_favorites[sessions_current_project_id.to_s][kind].include?(name)
  end

  def project_settings_link
    (sessions_project_selected? && is_superuser?) ? header_menu_link('Project', project_path(sessions_current_project), 'folder') : nil
  end

  def administration_link
    sessions_current_user.is_administrator? ? header_menu_link('Administration', administration_path, 'shield') : nil
  end

end

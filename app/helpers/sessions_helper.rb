# These are *controller* methods.
module SessionsHelper

  # User methods
  def sessions_signed_in?
    !sessions_current_user.nil?
  end

  def sessions_current_user=(user)
    @sessions_current_user = user
  end

  def sessions_current_user
    remember_token = User.encrypt(cookies[:remember_token])
    @sessions_current_user ||= User.find_by(remember_token: remember_token)
  end

  def sessions_current_user_id
    sessions_current_user ? sessions_current_user.id : nil
  end

  def sessions_sign_in(user)
    remember_token = User.secure_random_token
    cookies.permanent[:remember_token] = remember_token
    user.update_attribute(:remember_token, User.encrypt(remember_token))
    self.sessions_current_user = user
  end

  def sessions_sign_out
    self.sessions_current_user = nil
    cookies.delete(:remember_token)
  end

  # Project methods
  def sessions_project_selected?
    !sessions_current_project_id.nil?
  end

  def sessions_current_project_id=(project_id)
    @sessions_current_project_id = project_id
  end

  def sessions_current_project_id
    @sessions_current_project_id = session[:project_id]
  end

  def sessions_current_project
   return nil unless sessions_current_project_id 
   @sessions_current_project ||= Project.find(@sessions_current_project_id)
  end

  def sessions_select_project(project)
   self.sessions_current_project_id = project.id
   session[:project_id] = @sessions_current_project_id 
   @sessions_current_project ||= Project.find(@sessions_current_project_id)
  end

  def sessions_clear_selected_project
    session[:project_id] = nil
  end

  # Authorization methods
  def is_administrator?
    sessions_signed_in? && @sessions_current_user.is_administrator?
  end 

  def is_project_administrator?
    sessions_signed_in? && @sessions_current_user.is_project_administrator?
  end 

  def is_project_member?(user, project)
    project.members.include?(user) 
  end

  def authorize_project_selection(user, project)
    project.project_members.include?(user)
  end

  def require_sign_in
    redirect_to root_url, notice: "Please sign in." unless sessions_signed_in?
  end

  def require_project_selection
    redirect_to root_url, notice: "Please select a project." unless sessions_current_project?
  end

  def require_sign_in_and_project_selection
    redirect_to root_url, notice: "Whoa there, sign in and select a project first." unless sessions_signed_in? && sessions_current_project?
  end

  def require_adminstrator_sign_in
    redirect_to root_url, notice: "Please sign in as an administrator." unless is_administrator? 
  end

  def require_project_administrator_sign_in
    redirect_to root_url, notice: "Please sign in as a project administrator." unless is_project_administrator? 
  end

  # TODO: make this a non-controller method
  def session_header_links
    sessions_current_project ||= nil
    [link_to('Account', users_path(sessions_current_user)),
    (sessions_current_project ? link_to('Project', projects_settings_path(sessions_current_project)) : nil),
    (sessions_current_user.is_administrator? ? link_to('Account', users_path(sessions_current_user)) : nil),
    link_to('Sign out', signout_path, method: 'delete')].compact.join(' | ').html_safe
  end

end

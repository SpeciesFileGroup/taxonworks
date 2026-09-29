class Tasks::Projects::ColdpSettingsController < ApplicationController
  include TaskControllerConfiguration

  before_action :require_project_administrator_sign_in
  before_action :set_project

  def update
    if @project.update_coldp_settings(settings_params)
      render json: @project.coldp_preferences_for_vue(sessions_current_user)
    else
      render_project_error('Failed to update settings')
    end
  end

  private

  def set_project
    @project = Project.find(sessions_current_project_id)
    @recent_object = @project
  end

  def settings_params
    params.permit(:col_publication_reminder).to_h
  end

  def render_project_error(default_message)
    render json: { error: @project.errors.full_messages.join('; ').presence || default_message },
      status: :unprocessable_content
  end
end

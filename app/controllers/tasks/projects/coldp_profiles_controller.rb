class Tasks::Projects::ColdpProfilesController < ApplicationController
  include TaskControllerConfiguration

  before_action :require_project_administrator_sign_in
  before_action :set_project

  def create
    params.require(:otu_id)
    if @project.create_coldp_profile(profile_params)
      render json: @project.coldp_preferences_for_vue(sessions_current_user)
    else
      render_project_error('Failed to create profile')
    end
  end

  def update
    if @project.update_coldp_profile(profile_params)
      render json: @project.coldp_preferences_for_vue(sessions_current_user)
    else
      render_project_error('Failed to update profile')
    end
  end

  def destroy
    if @project.destroy_coldp_profile(params[:otu_id].to_i)
      render json: @project.coldp_preferences_for_vue(sessions_current_user)
    else
      render_project_error('Failed to destroy profile')
    end
  end

  def validate
    errors = Project::Coldp.metadata_yaml_errors(params[:metadata_yaml])
    render json: { errors: errors }
  end

  private

  def set_project
    @project = Project.find(sessions_current_project_id)
    @recent_object = @project
  end

  def profile_params
    params.permit(
      :otu_id, :checklistbank_dataset_id, :is_public,
      :default_user_id, :max_age, :metadata_yaml,
      :maintain_metadata_in_checklistbank, :base_url,
      :fossil_extinct, :default_lifezone, :prefer_unlabelled_otus
    ).to_h
  end

  def render_project_error(default_message)
    render json: { error: @project.errors.full_messages.join('; ').presence || default_message },
      status: :unprocessable_content
  end
end

class Tasks::AnatomicalParts::SelectOntologiesController < ApplicationController
  include TaskControllerConfiguration

  before_action :require_project_administrator_sign_in
  before_action :set_project

  def index
    # vue app
  end

  def save_ontologies_to_project
    @project.set_anatomical_parts_ontologies(params[:ontologies])

    head :no_content
  end

  def ontology_preferences
    render json: @project.anatomical_parts_ontology_preferences
  end

  private

  def set_project
    @project = Project.find(sessions_current_project_id)
    @recent_object = @project
  end

end
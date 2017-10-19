class AnnotationsController < ApplicationController

  before_action :require_sign_in_and_project_selection

  # GET /annotations/global_id
  def show
  end

  # GET /annotations/:global_id/metadata
  def metadata
    @object = GlobalID::Locator.locate(params[:global_id])

    render status: :not_found if @object.nil?
    render status: :unauthorized if not @object.project_id == sessions_current_project_id
  end

end

class AnnotationsController < ApplicationController

  before_action :require_sign_in_and_project_selection

  # GET /annotations/:global_id/metadata
  def metadata
    @object = GlobalID::Locator.locate(params.require(:global_id))
    render(json: { success: false}, status: :not_found) and return if @object.nil?
    render(json: { 'message' => 'Record not found' }, status: :unauthorized) if !@object.is_community? && @object.project_id != sessions_current_project_id
  end

  # GET /annotations/types (JSON)
  def types
  end
end

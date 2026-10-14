require_dependency 'hub/data'

# For controllers of Render (not Data) classes, e.g. Composition, see
# Shared::IsRender. Render records are project records (community ones are
# visible to all projects), so a project is required.
module RenderControllerConfiguration
  extend ActiveSupport::Concern

  included do
    before_action :require_sign_in_and_project_selection
    before_action :set_is_render_controller, :set_hub_model, :set_hub_model_metadata
  end

  protected

  def set_is_render_controller
    @is_render_controller = true
  end

  def set_hub_model
    @hub_model ||= controller_name.classify.safe_constantize
  end

  def set_hub_model_metadata
    @hub_model_metadata = Hub::Data::BY_NAME[@hub_model.name]
  end

end

require_dependency 'hub/data'

module DataControllerConfiguration
  extend ActiveSupport::Concern

  included do
    before_action :set_is_data_controller, :set_hub_model, :set_hub_model_metadata
  end

  protected

  def set_is_data_controller
    @is_data_controller = true
  end

  # !! This needs to be redefined in STI model controllers (e.g. see Georeferences::GeoLocates controller)
  # !! TODO- merge this into hub_model_metadata
  def set_hub_model
    @hub_model ||= controller_name.classify.safe_constantize # was constantize
  end

  def set_hub_model_metadata
    @hub_model_metadata = Hub::Data::BY_NAME[@hub_model.name]
  end

end

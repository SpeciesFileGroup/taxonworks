require_dependency 'hub/data'

module DataControllerConfiguration
  extend ActiveSupport::Concern

  included do
    before_action :set_is_data_controller, :set_data_model, :set_hub_model_metadata
  end

  def related
    if @data_model.is_community?
      @object = @data_model.find(params[:id])
    else
      @object = @data_model.where(project_id: sessions_current_project_id).find(params[:id])
    end

    render '/shared/data/project/related'
  end

  protected

  def set_is_data_controller
    @is_data_controller = true
  end

  # !! This needs to be redefined in STI model controllers (e.g. see Georeferences::GeoLocates controller)
  # !! TODO- merge this into hub_model_metadata
  def set_data_model
    @data_model = controller_name.classify.constantize
  end

  def set_hub_model_metadata
    @hub_model_metadata = Hub::Data::BY_NAME[@data_model.name]
  end

end

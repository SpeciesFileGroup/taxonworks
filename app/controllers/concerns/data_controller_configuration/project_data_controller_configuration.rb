module DataControllerConfiguration::ProjectDataControllerConfiguration 
  extend ActiveSupport::Concern

  included do
    include DataControllerConfiguration
    before_action :require_sign_in_and_project_selection
  end

  # protected (?)

  # @return [Hash]
  #    
  def polymorphic_filter_params(object_name, permitted_model_ids = [])
    h = params.permit(permitted_model_ids).to_h
    if h.size > 1 
      respond_to do |format|
        format.html { render plain: '404 Not Found', status: :unprocessable_entity and return }
        format.json { render json: {success: false}, status: :unprocessable_entity and return }
      end
    end

    model = h.keys.first.gsub(/_id$/, '').camelize
    return {"#{object_name}_type".to_sym => model,"#{object_name}_id".to_sym => h.values.first}
  end

end

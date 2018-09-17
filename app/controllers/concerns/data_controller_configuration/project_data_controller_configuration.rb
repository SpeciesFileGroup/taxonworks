module DataControllerConfiguration::ProjectDataControllerConfiguration 
  extend ActiveSupport::Concern

  included do
    include DataControllerConfiguration
    before_action :require_sign_in_and_project_selection
  end

  # protected (?)

  # @return [ Arel::Nodes, :unprocessable_entity ]
  #   wrap the the params gathering, if no valid params
  #   are provided return as unprocessable
  def annotator_params(params, klass)
    w = Queries::Annotator.annotator_params(params, klass)
    if w.nil?
      respond_to do |format|
        format.html { render plain: '404 Not Found', status: :unprocessable_entity and return }
        format.json { render json: {success: false}, status: :unprocessable_entity and return }
      end
    else
      w
    end
  end


end

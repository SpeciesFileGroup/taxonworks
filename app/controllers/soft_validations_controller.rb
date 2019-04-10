class SoftValidationsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :get_object

  # GET /soft_validations/validate
  def validate
    @object.soft_validate
    render json: {
      validations: @object.soft_validations
    }

  end

  # POST /soft_validations/fix?global_id=<>
  def fix
    @object.soft_validate
    @object.fix_soft_validations
    render json: {
      validations: @object.soft_validations
    }
  end

  protected

  def get_object
    @object = GlobalID::Locator.locate(URI.decode(params[:global_id]))
  end

end

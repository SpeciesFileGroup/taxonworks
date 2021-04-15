class SoftValidationsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :get_object

  # GET /soft_validations/validate
  def validate
    @object.soft_validate(soft_validate_params)
  end

  # POST /soft_validations/fix?global_id=<>
  def fix
    @object.soft_validate(soft_validate_params)
    @object.fix_soft_validations
  end

  protected

  def get_object
    @object = GlobalID::Locator.locate(URI.decode(params[:global_id] || ''))
    raise ActiveRecord::RecordNotFound if @object.nil?
  end

  def soft_validate_params
    params.permit(
      only_sets: [],
      only_methods: [],
      except_methods: [],
      except_sets: [],
    )
  end

end

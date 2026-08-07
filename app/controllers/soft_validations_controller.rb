class SoftValidationsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :get_object

  # GET /soft_validations/validate
  def validate
    @object.soft_validate(**soft_validate_params, include_flagged: true)
  end

  # POST /soft_validations/fix?global_id=<>
  def fix
    @object.soft_validate(**soft_validate_params, include_flagged: true) ## Use 'include_flagged: false' on all automatic fixes
    @object.fix_soft_validations
    render :validate
  end

  protected

  def get_object
    uri = URI::RFC2396_Parser.new.unescape(params[:global_id] || '')
    @object = GlobalID::Locator.locate(uri)
    raise ActiveRecord::RecordNotFound if @object.nil?
  end

  def soft_validate_params
    params.permit(
      only_sets: [],
      only_methods: [],
      except_methods: [],
      except_sets: [],
      include_flagged: [],
    ).to_h.symbolize_keys
  end

end

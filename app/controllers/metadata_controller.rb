class MetadataController < ApplicationController
  before_action :require_sign_in_and_project_selection

  def index
    @klass = params[:klass]
    render '/shared/data/metadata/index'
  end

  # :klass is a base class name, like "Otu"
  def object_radial 
    get_klass
    @data = OBJECT_RADIALS[@klass]
    render '/workbench/navigation/object_radial'
  end

  protected

  def get_klass
    render json: {status: 400} if (params[:type] && params[:global_id]) || (params[:type].blank? && params[:global_id].blank?)

    if params[:type]
      @klass = params[:type] 
      @object = nil
    else
      @object = GlobalID::Locator.locate(params.require(:global_id))
      @klass = OBJECT_RADIALS[@object.class.name] ? @object.class.name : @object.class.base_class.name
    end
  end

end

class MetadataController < ApplicationController
  before_action :require_sign_in_and_project_selection

  def index
    @klass = params[:klass]
    render '/shared/data/metadata/index'
  end

  # :klass is a base class name, like "Otu"
  def object_radial 

    @data = OBJECT_RADIALS[params[:klass]]
    render json: {} and return if @data.nil?

    render '/workbench/navigation/object_radial'
  end



end

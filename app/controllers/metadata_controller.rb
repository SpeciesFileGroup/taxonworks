class MetadataController < ApplicationController
  before_action :require_sign_in_and_project_selection

  def index
    @klass = params[:klass]
    render '/shared/data/metadata/index'
  end
  
end

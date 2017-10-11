class AnnotationsController < ApplicationController

  before_action :require_sign_in_and_project_selection

  # GET /annotations/global_id
  def show
  end

  # GET /annotations/:global_id/metadata
  def metadata
   @object = GlobalID::Locator.locate(params[:global_id])
  end

end

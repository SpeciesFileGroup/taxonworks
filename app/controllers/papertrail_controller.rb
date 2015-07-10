class PapertrailController < ApplicationController
  before_filter :require_sign_in_and_project_selection

  # GET /papertrail
  def papertrail
    @object = params[:object_type].constantize.find(params[:object_id])
  end

  def show
    @version = PaperTrail::Version.find(params[:id])
    @object = @version.item
    render 'papertrail'
  end

end

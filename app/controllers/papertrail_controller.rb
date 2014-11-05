class PapertrailController < ApplicationController
  before_filter :require_sign_in_and_project_selection

  # GET /hub
  def papertrail
    @object = params[:object_type].constantize.find(params[:object_id])
  end


end

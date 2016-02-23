class PapertrailController < ApplicationController
  before_filter :require_sign_in_and_project_selection

  # GET /papertrail
  def papertrail
    @object = params[:object_type].constantize.find(params[:object_id])
     record_not_found if invalid_object(@object)
  end

  def show
    @version = PaperTrail::Version.find(params[:id])
    @object = @version.item
    if invalid_object(@object) 
      record_not_found
    else
      render 'papertrail'
    end
  end

end

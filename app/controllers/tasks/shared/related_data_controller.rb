class Tasks::Shared::RelatedDataController < ApplicationController
  include TaskControllerConfiguration

  before_action :set_object

  def index
  end

  def set_object
    @object = GlobalID::Locator.locate(params[:object_global_id])

    if @object.nil? || (@object.project_id != sessions_current_project_id)
      render status: 404 and return
    end
  end

end

class Tasks::Shared::RelatedDataController < ApplicationController
  include TaskControllerConfiguration

  before_action :set_object

  def index
  end

  def set_object
    @object = GlobalID::Locator.locate(params[:object_global_id])

    # A nil project_id is a community record (e.g. an Identifier on a
    # Source, a community Template), not one in another project.
    if @object.nil? || (@object.respond_to?(:project_id) &&
        @object.project_id.present? &&
        @object.project_id != sessions_current_project_id)
      render status: 404 and return
    end
  end

end

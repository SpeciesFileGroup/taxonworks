class Tasks::Shared::RelatedDataController < ApplicationController
  include TaskControllerConfiguration

  before_action :set_object

  def index
  end

  def set_object
    @object = GlobalID::Locator.locate(params[:object_global_id])

    if @object.nil? || (@object.respond_to?(:project_id) &&
        @object.project_id != sessions_current_project_id &&
        !(@object.project_id.nil? && community_record?(@object)))
      render status: 404 and return
    end
  end

  private

  # A nil project_id alone is not trusted to mean community (it can be bad
  # data): the record must declare it, e.g. a community Template, or an
  # Identifier on a Source. Fails closed for everything else.
  def community_record?(object)
    (object.respond_to?(:is_community?) && object.is_community?) ||
      (object.respond_to?(:annotates_community_object?) &&
        object.annotates_community_object?)
  end

end

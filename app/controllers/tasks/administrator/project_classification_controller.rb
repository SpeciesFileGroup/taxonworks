class Tasks::Administrator::ProjectClassificationController < ApplicationController
  include TaskControllerConfiguration

  def index
    @data = helpers.taxonworks_classification(project_cutoff: (params[:project_cutoff] || 1000))
  end
end
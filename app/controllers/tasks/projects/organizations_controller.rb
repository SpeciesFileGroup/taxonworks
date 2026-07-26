class Tasks::Projects::OrganizationsController < ApplicationController
  include TaskControllerConfiguration
  before_action :require_superuser_sign_in

  # GET /tasks/projects/organizations/index
  def index
  end

end

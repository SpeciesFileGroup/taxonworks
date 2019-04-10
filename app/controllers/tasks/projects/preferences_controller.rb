class Tasks::Projects::PreferencesController < ApplicationController
  include TaskControllerConfiguration
  before_action :require_administrator_sign_in
  before_action :require_superuser_sign_in
  before_action :can_administer_projects?

  def index
  end

end

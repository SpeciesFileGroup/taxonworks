class HubController < ApplicationController
  before_action :require_sign_in_and_project_selection
  
  # GET /hub
  def index
  end
end

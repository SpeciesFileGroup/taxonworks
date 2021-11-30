class Tasks::Administrator::BatchAddUsersController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @users = []
  end

end

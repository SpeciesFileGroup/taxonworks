class Tasks::Administrator::BatchAddUsersController < ApplicationController
  include SuperuserControllerConfiguration

  # GET
  def index
    @users = []
  end

end

#
# This is a top-level class documentation comment for the Administration Controller
# RuboCop likes this
class AdministrationController < ApplicationController
  before_action :require_administrator_sign_in

  def index
  end

  def user_activity
  end

  def data_overview
  end
end

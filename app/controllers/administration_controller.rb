class AdministrationController < ApplicationController
  before_action :require_administrator_sign_in

  def index
  end

  def user_activity
  end
end

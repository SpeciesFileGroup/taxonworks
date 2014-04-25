require_relative 'initialization_constants' 

module ControllerSpecHelper
  def sign_in_user_and_select_project(user, project_id)
    @request.session = {project_id: project_id}
    remember_token = User.secure_random_token
    cookies.permanent[:remember_token] = remember_token
    user.update_attribute(:remember_token, User.encrypt(remember_token)) 
  end
end

RSpec.configure do |config|
  config.include ControllerSpecHelper, :type => :controller
end


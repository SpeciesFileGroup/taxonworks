
require_relative 'controller_spec_helper'

RSpec.configure do |config|
  config.include ControllerSpecHelper, :type => :controller
end

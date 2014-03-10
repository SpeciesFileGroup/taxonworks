require 'paperclip/matchers'
include ActionDispatch::TestProcess

RSpec.configure do |config|
  config.include Paperclip::Shoulda::Matchers
end

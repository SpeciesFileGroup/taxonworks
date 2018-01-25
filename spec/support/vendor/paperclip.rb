require 'paperclip/matchers'
include ActionDispatch::TestProcess

RSpec.configure do |config|
  config.include Paperclip::Shoulda::Matchers
end

# In general we can trigger callbacks when the transaction strategy is used by doing this:
#    i.destroy
#    i.run_callbacks(:commit)


require 'paperclip/matchers'
include ActionDispatch::TestProcess

RSpec.configure do |config|
  config.include Paperclip::Shoulda::Matchers
end

# In general we can trigger callbacks when the transaction strategy is used by doing this:
#    i.destroy
#    i.run_callbacks(:commit)
#
# However, for @project#nuke we currently maintain the original project/user, so we can not fully truncate.
# This is not optimum, we should move towards using truncate for spec/models/projects. For now, we cleanup
# manually.
# 
# !! The sub folder is automatically rebuilt during subsequent tests. 
def nuke_image_folder
  FileUtils.rm_rf(Dir["#{Rails.root}/spec/test_files/"])
end

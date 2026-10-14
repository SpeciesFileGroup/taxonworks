# What a class needs to be stepped through and shown in the shared views
# (app/views/shared/data/): previous/next navigation and edit/destroy
# permissions. Anything a shared view comes to depend on belongs here.
#
module Shared::IsSteppable

  extend ActiveSupport::Concern

  included do
    include Shared::Navigation
    include Shared::Permissions
  end

end

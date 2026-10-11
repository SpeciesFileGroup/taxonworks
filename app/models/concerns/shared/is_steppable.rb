# What a class needs to be stepped through and shown in the shared views
# (app/views/shared/data/): previous/next navigation and edit/destroy
# permissions. Annotation features are not included, views check
# AnnotationsHelper#annotatable? first. Anything a shared view comes to
# depend on belongs here.
#
module Shared::IsSteppable

  extend ActiveSupport::Concern

  included do
    include Shared::IsData::Navigation
    include Shared::Permissions
  end

end

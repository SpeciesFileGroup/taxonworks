# What a class needs to be stepped through and shown in the shared views
# (app/views/shared/data/): previous/next navigation, edit/destroy
# permissions, and annotation checks (all false for classes that can't be
# annotated). Anything a shared view comes to depend on belongs here.
#
module Shared::IsSteppable

  extend ActiveSupport::Concern

  included do
    include Shared::IsData::AnnotationTypes
    include Shared::IsData::Navigation
    include Shared::Permissions
  end

end

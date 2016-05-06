# Modules with this concern contain fixed Data provided at the application level.
#
module Shared::IsApplicationData
  extend ActiveSupport::Concern

  included do
  end

  class_methods do
    def is_community?
      true
    end
  end

end

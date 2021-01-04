# Modules with this concern contain fixed Data provided at the application level.
#
module Shared::IsApplicationData
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods
    def is_community?
      true
    end
  end

  delegate :is_community?, to: :class
end

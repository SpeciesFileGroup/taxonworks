# Thin wrapper around Thread.current for named thread-local storage.
#
# All thread-local reads and writes in TaxonWorks go through this module so
# that the underlying storage mechanism (Thread.current, Fiber.current,
# ActiveSupport::IsolatedExecutionState, etc.) can be swapped in one place.
module Utilities
  module ThreadStore
    def self.[](key)
      Thread.current[key]
    end

    def self.[]=(key, value)
      Thread.current[key] = value
    end
  end
end

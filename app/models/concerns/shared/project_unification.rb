# Concern for models that need custom conflict handling during project unification
#
# Include this concern in models that have complex validation logic requiring
# special handling when merging projects.
#
# @example Custom conflict handler
#   class MyModel < ApplicationRecord
#     include Shared::ProjectUnification
#
#     def handle_unify_conflict(target_project_id)
#       # Custom logic to resolve conflicts
#       self.some_field = "#{some_field}_migrated"
#     end
#   end
#
module Shared::ProjectUnification
  extend ActiveSupport::Concern

  included do
    # Override this method in models that need custom conflict resolution
    # Called during project unification when validation fails after project_id change
    #
    # @param target_project_id [Integer] The ID of the target project
    # @return [void]
    #
    # Default implementation does nothing - validation failures will be reported as errors
    def handle_unify_conflict(target_project_id)
      # Models can override this to implement custom conflict resolution
      # For example:
      # - Rename fields to avoid uniqueness conflicts
      # - Merge with existing records
      # - Skip migration of specific records
      # - Modify relationships
    end
  end

  module ClassMethods
    # Override to specify custom unification strategy for this model
    # @return [Symbol] :fast, :medium, :slow, or :skip
    def unification_track
      nil # Uses ModelClassifier default
    end
  end
end

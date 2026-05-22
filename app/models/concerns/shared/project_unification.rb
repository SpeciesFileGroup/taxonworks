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

  # Override this method in models that need custom conflict resolution.
  # Called by the migrator when validation fails (uniqueness conflict) after
  # project_id is changed to the target project.
  #
  # @param target_project_id [Integer] The ID of the target project
  #
  # @return [nil, false] handler did not persist — migrator will call save!
  # @return [true] handler persisted via update_columns — migrator skips
  #                save!, counts as migrated
  # @return [:destroyed] handler destroyed self (merged into existing target
  #                      record) — counts as destroyed
  def handle_unify_conflict(target_project_id)
  end
end

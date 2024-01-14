# TODO: DEPRECATE 
#
# Concerns that provides housekeeping and related methods for models that belong_to a creator and updator
#
module Housekeeping::CombinedScopes
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods
 
    # @param user_id [Integer]
    # @return [Scope]
    def touched_by(user_id)
      return self.none if user_id.blank?
      t = self.arel_table
      c = t[:updated_by_id].eq(user_id).or(t[:created_by_id].eq(user_id))
      where(c.to_sql)
    end

    # @param [Integer] project_id
    # @return [Scope]
    def recent_from_project_id(project_id)
      t = self.arel_table

      c = t[:project_id].eq(project_id).and(
        t[:created_at].gt(1.weeks.ago).
        or(t[:updated_at].gt(1.weeks.ago)
          )
      )

      where(c.to_sql)
    end

    # @param [Integer] limit
    # @return [Scope]
    def recently_updated(limit)
      self.order(updated_at: :desc).limit(limit)
    end

  end
end


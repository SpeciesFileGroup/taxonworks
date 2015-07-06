# Concern that provides housekeeping and related methods for models that belong_to a creator and updator
module Housekeeping::CombinedScopes
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods

    def recent_from_project_id(project_id)
      t = self.arel_table

      c = t[:project_id].eq(project_id).and(
        t[:created_at].gt(1.weeks.ago).
        or(t[:updated_at].gt(1.weeks.ago)
          )
      )

      where(c.to_sql) 
    end

  end

end


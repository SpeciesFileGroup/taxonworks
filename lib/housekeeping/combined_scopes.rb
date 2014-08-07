# Concern that provides housekeeping and related methods for models that belong_to a creator and updator
module Housekeeping::CombinedScopes
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods

    def recent_from_project_id(project_id)
      where(project_id: project_id).created_this_week
    end

    def recent_in_time(period)
      where.updated_in_last(period)
    end

  end

end


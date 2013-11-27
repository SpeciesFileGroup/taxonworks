# Concerns for models that are project specific and that have creator/updators
module Housekeeping 

   extend ActiveSupport::Concern
  included do
    include Users
    include Projects

    related_instances = self.name.underscore.pluralize.to_sym
    Project.class_eval do
      has_many related_instances
    end
  end
end

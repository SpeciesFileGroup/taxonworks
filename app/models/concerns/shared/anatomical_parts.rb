# Shared code for models which can serve as the 'taxonomic origin' of an
# anatomical part.
#
module Shared::AnatomicalParts
  extend ActiveSupport::Concern

  included do
    class_name = self.name.tableize.singularize

    has_many :anatomical_parts, as: :taxonomic_origin_object, inverse_of: :taxonomic_origin_object, dependent: :restrict_with_error
  end

  module ClassMethods

  end

end

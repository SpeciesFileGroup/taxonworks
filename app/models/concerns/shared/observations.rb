# Shared code for providing alternate values for individual columns.
#
module Shared::Observations
  extend ActiveSupport::Concern

  included do
    class_name = self.name.tableize.singularize

    has_many :observations, inverse_of: class_name, dependent: :restrict_with_error
    has_many :observation_matrix_rows, inverse_of: class_name 
    has_many :observation_matrix_row_items, inverse_of: class_name 
    has_many :observation_matrices, inverse_of: class_name.pluralize, through: :observation_matrix_rows
    has_many :descriptors, through: :observations
  end

  module ClassMethods
    def recently_observed
      joins(:observations).where(observations: { updated_at: 1.weeks.ago..Time.now } ) 
    end
  end

end

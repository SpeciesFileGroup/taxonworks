# Shared code for models that are observable.
#
module Shared::Observations
  extend ActiveSupport::Concern

  included do
    class_name = self.name.tableize.singularize

    # Descriptor subclasses may already exist so we
    # enumerate them all to insert the has_many.
    ::Descriptor.descendants.each do |k|
      k.class_eval do
        has_many class_name.tableize.to_sym, through: :observations, source: :observation_object, source_type: class_name.classify
      end
    end

    has_many :observations, as: :observation_object, dependent: :restrict_with_error,  inverse_of: :observation_object # inverse_of: class_name
    has_many :observation_matrix_rows, as: :observation_object , inverse_of: :observation_object
    has_many :observation_matrix_row_items, as: :observation_object, dependent: :destroy, inverse_of: :observation_object 
    has_many :observation_matrices, through: :observation_matrix_rows, inverse_of: class_name.pluralize.to_sym
    has_many :descriptors, through: :observations

    #  has_many :observation_matrix_rows, inverse_of: :observation_object, dependent: :delete_all
    #  has_many :observation_matrices, through: :observation_matrix_rows
    #  has_many :observation_matrix_row_items, inverse_of: class_name, dependent: :delete_all, class_name: 'ObservationMatrixRowItem::Single::Otu'
  end

  module ClassMethods
    def recently_observed
      joins(:observations).where(observations: { updated_at: 1.weeks.ago..Time.now } )
    end
  end

end

# Shared code for models for which a distribution can be asserted.
#
module Shared::AssertedDistributions
  extend ActiveSupport::Concern

  included do
    class_name = self.name.tableize.singularize

    has_many :asserted_distributions, as: :asserted_distribution_object, inverse_of: :asserted_distribution_object, dependent: :restrict_with_error
  end

  module ClassMethods

  end

end

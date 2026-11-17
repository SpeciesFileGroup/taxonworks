# Shared code for models for which an environment can be asserted.
#
module Shared::AssertedEnvironments
  extend ActiveSupport::Concern

  included do
    has_many :asserted_environments, as: :asserted_environment_object, inverse_of: :asserted_environment_object, dependent: :destroy
  end

  module ClassMethods

  end

end

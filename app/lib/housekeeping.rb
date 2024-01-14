module Housekeeping
  extend ActiveSupport::Concern

  included do
    include Users
    include Projects
    include Timestamps
    include CombinedScopes
    include AssociationHelpers
  end

  # @return [Boolean]
  def has_polymorphic_relationship?
    self.class.reflect_on_all_associations(:belongs_to).select { |a| a.polymorphic? }.count > 0
  end

end

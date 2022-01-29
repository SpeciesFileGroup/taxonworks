# Shared code for a classes that are "data" sensu TaxonWorks (things like Projects, users, and preferences are not data).
#
# !! This module must in included last !!
#
module Shared::IsData::Metamorphosize

  extend ActiveSupport::Concern

  # @return [Object]
  #   the same object, but namespaced to the base class
  #   used many places, might be good target for optimization
  def metamorphosize
    return self if self.class.descends_from_active_record?
    self.becomes(self.class.base_class)
  end
end

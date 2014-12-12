module Shared::IsData
  extend ActiveSupport::Concern

  included do
    include Pinnable
  end

  def metamorphosize
    return self if self.class.descends_from_active_record?
    self.becomes(self.class.base_class)
  end


  def has_alternate_values?
    self.ancestors.include?(Shared::AlternateValues)
  end


  def has_citations?
    self.ancestors.include?(Shared::Citable)
  end

end

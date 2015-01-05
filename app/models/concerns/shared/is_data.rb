module Shared::IsData
  extend ActiveSupport::Concern

  included do
    include Pinnable
  end

  def metamorphosize
    return self if self.class.descends_from_active_record?
    self.becomes(self.class.base_class)
  end

  # Determines whether the instance can be annotated
  # in one of the following ways
  def has_alternate_values?
    self.class.ancestors.include?(Shared::AlternateValues)
  end

  def has_citations?
    self.class.ancestors.include?(Shared::Citable)
  end

  def has_identifiers?
    self.class.ancestors.include?(Shared::Identifiable)
  end

  def has_notes?
    self.class.ancestors.include?(Shared::Notable)
  end

  def has_tags?
    self.class.ancestors.include?(Shared::Taggable)
  end

  # Also need to check has_one relationships
  def is_in_use?
    self.class.reflect_on_all_associations(:has_many).each do |r|
      return true if self.send(r.name).count > 0
    end
    false
  end

end

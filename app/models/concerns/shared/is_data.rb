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
    self.class < Shared::AlternateValues ? true : false
  end

  def has_citations?
    self.class < Shared::Citable ? true : false
  end

  def has_data_attributes?
    self.class < Shared::DataAttributes ? true : false
  end

  def has_identifiers?
    self.class < Shared::Identifiable ? true : false
  end

  def has_notes?
    self.class < Shared::Notable ? true : false
  end

  def has_tags?
    self.class < Shared::Taggable ? true : false
  end

  # Also need to check has_one relationships
  def is_in_use?
    self.class.reflect_on_all_associations(:has_many).each do |r|
      return true if self.send(r.name).count > 0
    end
    false
  end

  def is_community?
    self.class < Shared::SharedAcrossProjects ? true : false
  end

  # @return [#annotations_hash]
  #    an accessor for the annotations_hash, overwritten by some inheriting classes
  def annotations
    annotations_hash
  end

  module ClassMethods
  end

  protected


  # Contains all "annotations" for this instance
  # @return [Hash]
  def annotations_hash
    result = {}
    result.merge!('alternate values' => self.alternate_values) if self.has_alternate_values? && self.alternate_values.any?
    result.merge!('citations' => self.citations) if self.has_citations? && self.citations.any?
    result.merge!('data attributes' => self.data_attributes) if self.has_data_attributes? && self.data_attributes.any?
    result.merge!('identifiers' => self.identifiers) if self.has_identifiers? && self.identifiers.any?
    result.merge!('notes' => self.notes) if self.has_notes? && self.notes.any?
    result.merge!('tags' => self.tags) if self.has_tags? && self.tags.any?
    result
  end

end

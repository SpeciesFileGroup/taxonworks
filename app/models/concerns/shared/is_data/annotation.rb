

module Shared::IsData::Annotation

  extend ActiveSupport::Concern

  ANNOTATION_TYPES = [
    :alternate_values,
    :citations,
    :data_attributes,
    :identifiers,
    :notes,
    :documentation,
    :tags,
    :confidences,
    :depictions,
    :protocols,
    :identifiers
  ]

  #  included do
  #  end

  module ClassMethods

    # @return [Boolean]
    # true if model is an "annotator" (e.g. identifiers, tags, notes, data attributes, alternate values, citations), i.e. data that references another data element through STI
    def annotates?
      respond_to?(:annotated_object)
    end
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

  def has_confidences?
    self.class < Shared::Confidence ? true : false
  end

  def has_depictions?
    self.class < Shared::Depictions ? true : false
  end

  def is_loanable? 
    self.class < Shared::Loanable ? true : false
  end

  def has_protocols?
    self.class < Shared::Protocols ? true : false
  end

  def has_documentation?
    self.class < Shared::Documentation ? true : false
  end

  # @return [#annotations_hash]
  # an accessor for the annotations_hash, overwritten by some inheriting classes
  def annotations
    annotations_hash
  end

  def available_annotation_types
    ANNOTATION_TYPES.select do |a|
      self.send("has_#{a}?")
    end
  end

  def annotation_metadata
    available_annotation_types.inject({}){|hsh, a| hsh.merge!(a => {total: send(a).count})}
  end

  protected

  # @return [Hash]
  # Contains all "annotations" for this instance
  def annotations_hash
    result = {}
    result['citations'] = self.citations if self.has_citations? && self.citations.any?
    result['data attributes'] = self.data_attributes if self.has_data_attributes? && self.data_attributes.any?
    result['identifiers'] = self.identifiers if self.has_identifiers? && self.identifiers.any?
    result['notes'] = self.notes if self.has_notes? && self.notes.any?
    result['tags'] = self.tags if self.has_tags? && self.tags.any?

    result['depictions'] = self.depictions.order('depictions.position') if self.has_depictions? && self.depictions.any?
    result['confidences'] = self.confidences if self.has_confidences? && self.confidences.any?
    result['protocols'] = self.protocols if self.has_protocols? && self.protocols.any?
    result['alternate values'] = self.alternate_values if self.has_alternate_values? && self.alternate_values.any?
    result
  end

end



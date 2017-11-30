

module Shared::IsData::Annotation

  extend ActiveSupport::Concern

  ANNOTATION_TYPES = [
    :alternate_values,
    :citations,
    :data_attributes,
    :notes,
    :documentation,
    :tags,
    :confidences,
    :depictions,
    :protocols,
    :identifiers
  ]

  module ClassMethods

    # @return [Boolean]
    # true if model is an "annotator" (e.g. identifiers, tags, notes, data attributes, alternate values, citations), i.e. data that references another data element through STI
    def annotates?
      respond_to?(:annotated_object)
    end

    # Determines whether the class can be annotated
    # in one of the following ways
    ANNOTATION_TYPES.each do |t|
      define_method("has_#{t}?") do
        k = "Shared::#{t.to_s.singularize.classify.pluralize}".safe_constantize
        self < k ? true : false
      end
    end
  
  end

  # Determines whether the instance can be annotated
  # in one of the following ways
  ANNOTATION_TYPES.each do |t|
    define_method("has_#{t}?") do
      k = "Shared::#{t.to_s.singularize.classify.pluralize}".safe_constantize
      self.class < k ? true : false
    end
  end

  def has_loans?
    self.class < Shared::Loanable ? true : false
  end

  # @return [#annotations_hash]
  #   an accessor for the annotations_hash, overwritten by some inheriting classes
  def annotations
    annotations_hash
  end

  def available_annotation_types
    ANNOTATION_TYPES.select do |a|
      self.send("has_#{a}?")
    end
  end

  # @return [Hash]
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




module Shared::IsData::Annotation

  extend ActiveSupport::Concern

  # This is indirectly responsible for
  # visual position placement in radial annotator
  # middle is left, top/bottom right

  # see config/initializes/constanst/model/annotations for types
  #
  included do

    # @return [Boolean]
    # true if model is an "annotator" (e.g. identifiers, tags, notes, data attributes, alternate values, citations), i.e. data that references another data element through STI
    def annotates?
      respond_to?(:annotated_object)
    end

    # TODO: consider implications of allowing cloning from any objet
    # to any object
    # This should be wrapped in a larger transction
    def clone_annotations(to_object: nil, except: [], only: [])
      return false if to_object.nil?
      a = !only.empty? ? only : (::ANNOTATION_TYPES - except)
      a.each do |t|
        if respond_to?(t)
          send(t).each do |o|
            o.dup
            to_object.send(t) << o
          end
        end
      end
      to_object
    end
  end

  # TODO: consider implications of allowing cloning from any object
  # to any object
  def move_annotations(to_object: nil, except: [], only: [])
    return false if to_object.nil?

    e = except.map(&:to_sym)
    o = only.map(&:to_sym)

    errors = []

    a = !only.empty? ? o : (::ANNOTATION_TYPES - e)
    a.each do |t|
      if respond_to?(t)
        send(t).each do |i|
          i.annotated_object = to_object

          begin
            i.save!
          rescue ActiveRecord::RecordInvalid => e
            errors.push e
          end

        end
      end
    end
    errors
  end


  module ClassMethods

    def annotates?
      self < Shared::PolymorphicAnnotator ? true : false
    end

    # Determines whether the class can be annotated
    # in one of the following ways
    ::ANNOTATION_TYPES.each do |t|
      define_method("has_#{t}?") do
        k = "Shared::#{t.to_s.singularize.classify.pluralize}".safe_constantize
        self < k ? true : false
      end
    end

    def available_annotation_types
      ::ANNOTATION_TYPES.collect do |a|
        self.send("has_#{a}?") ? a.to_s.classify : nil
      end.compact
    end
  end

  # Determines whether the instance can be annotated
  # in one of the following ways
  ::ANNOTATION_TYPES.each do |t|
    define_method("has_#{t}?") do
      k = "Shared::#{t.to_s.singularize.classify.pluralize}".safe_constantize
      self.class < k ? true : false
    end
  end

  def available_annotation_types
    ::ANNOTATION_TYPES.select do |a|
      self.send("has_#{a}?")
    end
  end

  # Doesn't belong here
  def has_loans?
    self.class < Shared::Loanable ? true : false
  end

  # @return [Hash]
  #   an accessor for the annotations_hash, overwritten by some inheriting classes
  def annotations
    annotations_hash
  end

  # @return [Hash]
  def annotation_metadata(project_id = nil)
    h = {}

    # Use a fixed order for UI stability
    ANNOTATION_TYPES.each do |t|
      next unless available_annotation_types.include?(t)
      case t

      when :documentation

        if project_id
          h[:documentation] = {total: documentation.where(documentation: {project_id:}).count}
        else
          h[:documentation] = {total: ( send(:documentation).count) }
        end

      when :attribution
        h[:attribution] = {total: (send(:attribution).present? ? 1 : 0)}
      when :identifiers

        if project_id
          h[:identifiers] = {total: ( send(:identifiers).visible(project_id).count)}
        else
          h[:identifiers] = {total: ( send(:identifiers).count) }
        end
      else
        h[t] = { total: send(t).count }
      end
    end
    h
  end

  protected

  # @return [Hash]
  # Contains all "annotations" for this instance
  def annotations_hash
    result = {}
    result['citations'] = citations if has_citations? && citations.load.any? # Use load since we nearly always are going ot reference the result
    result['data attributes'] = data_attributes if has_data_attributes? && data_attributes.load.any?
    result['identifiers'] = identifiers if has_identifiers? && identifiers.load.any? # !! TODO:  Load is broken here.
    result['notes'] = notes if has_notes? && notes.load.any?
    result['tags'] = tags if has_tags? && tags.load.any?
    result['depictions'] = depictions.order('depictions.position') if has_depictions? && depictions.load.any?
    result['confidences'] = confidences if has_confidences? && confidences.load.any?
    result['protocol relationships'] = protocols if has_protocol_relationships? && protocolled?
    result['alternate values'] = alternate_values if has_alternate_values? && alternate_values.load.any?
    result['attribution'] = attribution if has_attribution? && attribution.load.any?

    result['verifiers'] = verifiers if has_verifiers? && verifiers.load.any?
    result
  end

end

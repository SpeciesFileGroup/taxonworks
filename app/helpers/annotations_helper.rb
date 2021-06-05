# Helpers that wrap sets of annotations of different types.
module AnnotationsHelper 

  # @return [String]
  # Assumes the context is the object, not a multi-object summary
  def annotations_summary_tag(object)
    content_tag(:div, class: %w{item panel separate-bottom}) do
      content_tag(:div, class: [:content]) do
        content_tag(:div, class: ['information-panel']) do
          content_tag(:h2, 'Annotations') +
            content_tag(:div,
            [citation_list_tag(object),
             identifier_list_tag(object), 
             data_attribute_list_tag(object), 
             note_list_tag(object), 
             tag_list_tag(object),
             alternate_values_list_tag(object),
             confidence_list_tag(object),
             attribution_list_tag(object)
          ].compact.join.html_safe, class: :annotations_summary_list, 'data-annotator-list-object-id' => object.id)

        end
      end
    end

    # depictions
    # confidences
    # protocols

  end

  def annotations_exist(object)
    return (object.has_citations? && object.citations.any?) || 
      (object.has_identifiers? && object.identifiers.any?) ||
      (object.has_data_attributes? && object.data_attributes.any?) ||
      (object.has_notes? && object.notes.any?) ||
      (object.has_tags? && object.tags.load.any?) ||
      (object.has_alternate_values? && object.alternate_values.any?) ||
      (object.has_confidences? && object.confidences.any?) ||
      (object.has_attribution? && object.attribution)
  end

  def annotation_id(object)
    "annotation_anchor_#{object.metamorphosize.class.name}_#{object.id}"
  end

  def radial_annotator(object, pulse = false, showCount = false)
    content_tag(:div, '', data: { 'global-id' => object.to_global_id.to_s, 'radial-annotator' => 'true', 'show-count' => showCount, 'pulse' => pulse })
  end

  # @return [Array]
  #   of { ClassName => human name } 
  def klass_and_labels(klass_names)
    klass_names.collect{|n| [n, n.tableize.humanize]}.to_h
  end

end

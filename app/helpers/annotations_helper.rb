# Helpers that wrap sets of annotations of different types.
module AnnotationsHelper

  # @return Hash
  # Models name as key, annotator names as Array of values
  #   see /metadata/annotators.json
  def klass_annotations
    j = {}
     ::Project::MANIFEST.sort.each do |m|
       k = m.safe_constantize
       if k.respond_to?(:available_annotation_types) 
        j[k.name] = k.available_annotation_types
       end
     end
    j
  end

  # @return [String]
  # Assumes the context is the object, not a multi-object summary
  def annotations_summary_tag(object)
    v = [citation_list_tag(object),
        identifier_list_tag(object),
        data_attribute_list_tag(object),
        note_list_tag(object),
        tag_list_tag(object),
        alternate_values_list_tag(object),
        confidence_list_tag(object),
        attribution_list_tag(object)
    ].compact

    tag.div(class: %w{item panel separate-bottom}) do
      tag.div(class: [:content]) do
        tag.div(class: ['information-panel']) do
          tag.h2('Annotations') +
            ( v.count > 0 ?  tag.div(v.join.html_safe, class: :annotations_summary_list, 'data-annotator-list-object-id' => object.id) : tag.em('None'))
        end
      end
    end

    # depictions
    # confidences
    # protocols
  end

  def annotations_exist(object)
    return (object.has_citations? && object.citations.any?) ||
      (object.has_identifiers? && object.identifiers.visible(sessions_current_project_id).any?) ||
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

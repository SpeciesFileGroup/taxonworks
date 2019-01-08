module LabelsHelper

  def label_tag(label)
    return nil if label.nil?
    content_tag(:span, label.text, class: label.style) # TODO: properly reference style
  end

  def label_link(label)
    return nil if label.nil?
    if label.label_object_id.blank?
      label_tag(label)
    else
      link_to(content_tag(:span, label.text, class: label.style), label.object_global_id) # TODO: properly reference style
    end
  end

end

module LabelsHelper

  # !! Note that `label_tag` is a Rails reserved word, so we have to append and make exceptions
  def taxonworks_label_tag(label)
    return nil if label.nil?
    content_tag(:span, label.text) # TODO: properly reference style
  end

  def label_link(label)
    return nil if label.nil?
    if label.label_object_id.blank?
      taxonworks_label_tag(label)
    else
      link_to(content_tag(:span, label.text), label.object_global_id) # TODO: properly reference style
    end
  end

end

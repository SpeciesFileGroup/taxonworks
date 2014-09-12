module ApplicationHelper

  def scrollable_div_tag(text)
    return nil if text.blank?
    content_tag(:div, text, class: :scrollable_div)
  end

  # TODO: Move
  def similarly_named_records_list(instance)
    model   = instance.class
    name    = instance.name
    records = model.where(['(name LIKE ? OR NAME like ?) AND id != ?', "#{name}%", "%#{name}%", instance]).limit(5)
    content_tag(:span) do
      content_tag(:em, 'Similarly named records: ') +
        content_tag(:span) do
          (records.count == 0 ?
            'none' :
            records.collect { |r| link_to(r.name, r) }.join(', ').html_safe)
        end
    end
  end

  # Set @no_turbolinks in a before_action, then use the method in, say a layout.
  def turbolinks_off_tag
    'data-no-turbolink="true"'.html_safe if @no_turbolinks
  end

  def model_name_title
    controller_name.humanize.titleize
  end

  def object_attributes_partial_path(object)
    "/#{object.class.base_class.name.tableize}/attributes"
  end

  def batch_preview_model_path
    send("batch_preview_#{controller_name.to_s.pluralize}_path")
  end

  def hidden_css_property_if(tru)
    tru ? 'hidden'.html_safe : nil
  end

  def collapsed_css_property_if(tru)
    tru ? 'collapsed'.html_safe : nil
  end

end

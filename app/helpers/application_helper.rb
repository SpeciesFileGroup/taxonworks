module ApplicationHelper

  def scrollable_div_tag(text)
    return nil if text.blank?
    content_tag(:div, text, class: :scrollable_div)
  end

  def similarly_named_records_list(instance)
    model = instance.class
    name = instance.name
    records = model.where(['name like ? OR name like ?', "#{name}%", "%#{name}%"]).limit(5)
    content_tag(:span) do
      content_tag(:em, 'Similarly named records: ' ) +
        content_tag(:span) do
        (records.count == 0 ?
         'none' :
         records.collect{|r| link_to(r.name, r) }.join(', ').html_safe)
      end
    end
  end

  # !! Dangerous, not scoped by project, and not bound, also assumes -1 TODO: FIX
  def previous_by_id_link(instance)
    link_id = instance.id.to_i - 1
    if link_id <= 1
      return 'Previous'
    else
      link_to('Previous', instance.class.find(link_id) )
    end
  end

  # !! Dangerous, not scoped by project: TODO: FIX
  def next_by_id_link(instance)
    link_id = instance.id.to_i + 1
    if link_id >= instance.class.count
      return 'Next'
    else
      link_to('Next', instance.class.find(link_id) )
    end
  end

  def forward_back_links(instance)
    content_tag(:span,  (previous_by_id_link(instance) + ' | ' + next_by_id_link(instance)).html_safe )
  end

  # !! Dangerous, not scoped by project, and not bound, also assumes -1 TODO: FIX
  def previous_page(instance)
    text = 'Previous page'
    link_id = instance.id.to_i - 1
    if link_id <= 1
      return text
    else
      link_to(text, instance.class.find(link_id) )
    end
  end

  # !! Dangerous, not scoped by project: TODO: FIX
  def next_page(instance)
    text = 'Next page'
    link_id = instance.id.to_i + 1
    if link_id >= instance.class.count
      return text
    else
      link_to(text, instance.class.find(link_id) )
    end
  end

  # !! Get rid of this too TODO: FIX
  def forward_back_pages(instance)
    content_tag(:span,  (previous_page(instance) + ' | ' + next_page(instance)).html_safe )
  end


  def model_name_title
    controller_name.humanize.titleize
  end

  def hidden_css_property_if(tru)
    tru ? 'hidden'.html_safe : nil
  end

  def collapsed_css_property_if(tru)
    tru ? 'collapsed'.html_safe : nil
  end

end

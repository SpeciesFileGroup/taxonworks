module ApplicationHelper

  def scrollable_div_tag(text)
    return nil if text.blank?
    content_tag(:div, text, class: :scrollable_div)
  end

  def similarly_named_records_list(instance)
    model = instance.class
    records = model.with_name_like(instance.name)
    content_tag(:div) do
      content_tag(:strong, 'Similarly named records: ' ) +
        content_tag(:span) do
        (records.count == 0 ?
         'none' :
         records.collect{|r| link_to(r.name, r) }.join(', ').html_safe)
      end
    end
  end

  # !! Dangerous, not scoped by project, and not bound
  def previous_by_id_link(instance)
    link_id = instance.id.to_i - 1
    if link_id <= 1
      return 'Previous'
    else
      link_to('Previous', instance.class.find(link_id) )
    end 
  end

  # !! Dangerous, not scoped by project
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


end

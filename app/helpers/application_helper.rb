module ApplicationHelper


  def scrollable_div_tag(text)
    content_tag(:div, text, class: :scollable_div)
  end

  def similarly_named_records_list(instance)
    model = instance.class.name.constantize
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

end

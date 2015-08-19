module BatchLoad::BatchLoadHelper

  def warn_level_input(result)
    str     = "Import level:<br>&nbsp;"
    options = [radio_button_tag(:import_level, :warn, selected: true) + ' warn']
    options << radio_button_tag(:import_level, :line_strict) + ' line strict' if result.line_strict_level_ok?
    options << radio_button_tag(:import_level, :strict) + ' strict' if result.strict_level_ok?
    str += options.join('<br>&nbsp;').html_safe
    content_tag(:div, str.html_safe)
  end

  def batch_data_created_td(rp)
    content_tag :td do
      content_tag :table do
        rp.objects.collect { |klass, objs|
          content_tag(:tr, content_tag(:td, klass), class: 'underlined_elements') +
            objs.collect { |o| content_tag(:tr,
                                           content_tag(:td,
                                                       o.persisted? ? object_link(o) : content_tag(:span, object_tag(o), class: 'warning')
                                           )
            )
            }.join.html_safe
        }.join.html_safe
      end
    end
  end

  def batch_data_errors_td(rp)
    content_tag(:td) do
      content_tag(:table, border: true) do
        rp.objects.collect { |klass, objs|
          content_tag(:tr, content_tag(:td, "-") +
                           objs.collect { |o|
                             content_tag(:tr,
                                         content_tag(:td, (o.valid? ? content_tag(:span, 'None.', class: 'subtle') : "#{o.errors.full_messages.join('; ')}"))
                             )
                           }.join.html_safe
          )
        }.join.html_safe
      end
    end
  end

  def batch_parse_errors_td(rp)
    content_tag(:td, rp.parse_errors.join('; ').html_safe)
  end

  def batch_valid_objects_td(rp)
    content_tag(:td, rp.has_valid_objects? ? rp.valid_objects.length : 0)
  end

  def batch_all_objects_count_td(rp)
    content_tag(:td, rp.total_objects)
  end

  def batch_line_link_td(line)
    content_tag(:td, link_to(line, "#line_#{line}", id: "parse_#{line}").html_safe)
  end

end

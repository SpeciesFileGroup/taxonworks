module BatchLoad::BatchLoadHelper

  def warn_level_input(result)
    str = 'Import level:<br>&nbsp;'
    options = [radio_button_tag(:import_level, :warn, selected: true) + ' warn']
    options << radio_button_tag(:import_level, :line_strict) + ' line strict' if result.line_strict_level_ok?
    options << radio_button_tag(:import_level, :strict) + ' strict' if result.strict_level_ok?
    str += options.join('<br>&nbsp;').html_safe
    content_tag(:div, str.html_safe)
  end

  # @param rp
  def batch_data_created_td(rp)
    content_tag :td do
      content_tag :table do
        rp.objects.collect { |klass, objs|
          content_tag(:tr, content_tag(:td, klass), class: 'underlined_elements') +
            objs.collect { |o| content_tag(
              :tr,
              content_tag(
                :td,
                o.persisted? ? object_link(o) : content_tag(:span, object_tag(o), class: 'feedback feedback-warning')
              )
            )
            }.join.html_safe
        }.join.html_safe
      end
    end
  end

  def batch_data_errors_td(rp, sep = '; ')

    errors = {}
    rp.objects.each do |klass, objs| 
      objs.each do |o|
        if !o.valid?
          errors[klass] ||= []
          errors[klass].push o.errors.full_messages.join(sep)
        end
      end
    end

    content_tag(:td) do
      content_tag(:table, border: true) do
        errors.collect { |klass, objs|
          content_tag(:tr, content_tag(:th, klass) +
                      objs.collect { |o|
                        content_tag(:tr, content_tag(:td, o, class: 'feedback feedback-thin feedback-warning').html_safe)
                      }.join.html_safe
                     )
        }.join.html_safe
      end
    end
  end

  def batch_parse_errors_td(rp, sep = '; ')
    content_tag(:td, rp.parse_errors.join(sep).html_safe)
  end

  def batch_valid_objects_td(rp)
    tag.td(rp.has_valid_objects? ? rp.valid_objects.length : 0)
  end

  def batch_all_objects_count_td(rp)
    tag.td rp.total_objects
  end

  def batch_line_link_td(line)
    content_tag(:td, link_to(line, "#line_#{line}", id: "parse_#{line}", data: {'turbolinks': false}).html_safe)
  end

  def batch_otu_name_td(otu)
    if otu.present?
      content_tag(:td, "'#{otu.name}'" + (otu.new_record? ? '<br>(New)' : '').html_safe)
    else
      ('<td></td>').html_safe
    end
  end

end
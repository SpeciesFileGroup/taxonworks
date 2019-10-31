module SerialsHelper

  def serial_tag(serial)
    return nil if serial.nil?
    serial.name
  end

  def serial_autocomplete_tag(serial, term = '')
    return nil if serial.nil?
    [ serial.name.gsub(/#{Regexp.escape(term)}/, "<mark>#{term}</mark>"), 
      content_tag(:span, "Project uses: #{Serial.joins(sources: [:project_sources]).where('project_sources.project_id = ? and serials.id = ?', sessions_current_project_id, serial.id).count}", class: [:feedback, 'feedback-primary', 'feedback-thin']),
      content_tag(:span, "All uses: #{serial.sources.count}", class: [:feedback, 'feedback-secondary', 'feedback-thin'])

    ].join('&nbsp;').html_safe
  end

  def serial_link(serial)
    return nil if serial.nil?
    link_to(serial_tag(serial).html_safe, serial)
  end

  def serials_search_form
    render('/serials/quick_search_form')
  end

  def serial_for_select(serial)
    serial.name if serial
  end
end

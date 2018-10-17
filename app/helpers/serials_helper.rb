module SerialsHelper

  def serial_tag(serial)
    return nil if serial.nil?
    serial.name
  end

  def serial_autocomplete_tag(serial, term = '')
    return nil if serial.nil?
    show_this =  serial.name.gsub(/#{Regexp.escape(term)}/, "<mark>#{term}</mark>") # weee bit simpler
    # show_this += " (#{geographic_area.geographic_area_type.name})" unless geographic_area.geographic_area_type.nil?
    # show_this += " [#{geographic_area.parent.name}]" unless geographic_area.parent.nil?
    show_this.html_safe
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

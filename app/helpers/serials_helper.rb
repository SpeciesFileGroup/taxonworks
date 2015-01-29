module SerialsHelper

  def self.serial_tag(serial)
    return nil if serial.nil?
    serial.name
  end

  def serial_tag(serial)
    SerialsHelper.serial_tag(serial)
  end

  def serial_link(serial)
    return nil if serial.nil?
    link_to(SerialsHelper.serial_tag(serial).html_safe, serial)
  end

  def serials_search_form
    render('/serials/quick_search_form')
  end

end

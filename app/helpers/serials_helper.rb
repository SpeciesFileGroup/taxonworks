module SerialsHelper

  def self.serial_tag(serial)
    return nil if serial.nil?
    serial.name
  end

  def serial_tag(serial)
    SerialsHelper.serial_tag(serial)
  end

end

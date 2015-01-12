module SerialsHelper

  def self.serial_tag(serial)
    return nil if serial.nil?
    serial.name
  end

  def serial_tag(serial)
    SerialsHelper.serial_tag(serial)
  end

  def tasks_serials_serial_similar_link(serial)
    # options = {}
    # priority = [serial.container, serial.identifiers.first, serial ].compact.first
    # link_to('Similar serials', verify_accessions_task_path(by: priority.metamorphosize.class.name.tableize.singularize.to_sym, id: priority.to_param))
    link_to('Similar serials', tasks_serials_serial_similar_path(@serial))
  end

end

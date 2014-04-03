class Georeference::VerbatimData < Georeference

  def xlate_lat_long
    # get the data from the parent.collecting_event, and make a point of it
    geographic_item.point = Georeference::FACTORY.point(collecting_event.verbatim_longitude.to_f,
                                                        collecting_event.verbatim_latitude.to_f,
                                                        collecting_event.minimum_elevation.to_f)
  end
end

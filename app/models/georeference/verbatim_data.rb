class Georeference::VerbatimData < Georeference

  def initialize(params = {}) # no available parms

    super

    self.is_median_z    = false
    self.is_undefined_z = false # and delta_z is zero, or ignored

    if collecting_event.nil?
    else
      # get the data from the parent.collecting_event, and make a point of it
      lat  = collecting_event.verbatim_latitude.to_f
      long = collecting_event.verbatim_longitude.to_f

      # value from collecting_event is normalised to meters
      z1   = collecting_event.minimum_elevation
      z2   = collecting_event.maximum_elevation
      if z1.blank?
        # no valid elevation provided
        self.is_undefined_z = true
        delta_z        = 0.0
      else
        # we have at least half of the range data
        delta_z = z1
        if z2.blank?
          # we have *only* half of the range data
          delta_z = z1
        else
          # we have full range data, so elevation is (top - bottom) / 2
          z2 = z2.to_f
          delta_z = (z2 - z1) * 0.5
          # and show calculated median
          self.is_median_z = true
        end
      end
      geographic_item       = GeographicItem.new
      geographic_item.point = Georeference::FACTORY.point(long, lat, delta_z)
    end
  end

  def xlate_lat_long
  end
end

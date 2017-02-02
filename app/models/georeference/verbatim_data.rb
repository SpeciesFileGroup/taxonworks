# Verbatim data definition...
#
class Georeference::VerbatimData < Georeference

  def initialize(params = {})
    super

    self.is_median_z    = false
    self.is_undefined_z = false # and delta_z is zero, or ignored

    unless collecting_event.nil? || geographic_item

      # value from collecting_event is normalised to meters
      z1 = collecting_event.minimum_elevation
      z2 = collecting_event.maximum_elevation
      if z1.blank?
        # no valid elevation provided
        self.is_undefined_z = true
        delta_z             = 0.0
      else
        # we have at least half of the range data
        # delta_z = z1
        if z2.blank?
          # we have *only* half of the range data
          delta_z = z1
        else
          # we have full range data, so elevation is (top - bottom) / 2
          #z2               = z2.to_f
          delta_z          = z1 + ((z2 - z1) * 0.5)
          # and show calculated median
          self.is_median_z = true
        end
      end

      point      = collecting_event.verbatim_map_center(delta_z)
      attributes = {point: point}
      attributes[:by] = self.by if self.by

      if point.nil?
        test_grs = []
      else
        test_grs = GeographicItem::Point.where("point = ST_GeographyFromText('POINT(#{point.x} #{point.y})::geography')").where("ST_Z(point::geometry) = #{point.z}")
      end

      if test_grs.empty?
        test_grs = [GeographicItem.new(attributes)]
      end

      self.geographic_item = test_grs.first
    end

    geographic_item
  end
end

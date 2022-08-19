# The Georeference that is derived exclusively from verbatim_latitude/longitude and  fields in a CollectingEvent.
#
# While it might be concievable that verbatim data are WKT shapes not points, we assume they are for now.
#
#
# !! TODO: presently does not include verbatim_geolocation_uncertainty translation into radius
# !! See https://github.com/SpeciesFileGroup/taxonworks/issues/1770
# @param error_radius
#   is taken from collecting_event#verbatim_geolocation_uncertainty
class Georeference::VerbatimData < Georeference

  # @param [ActionController::Parameters] params
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
          delta_z = z1 + ((z2 - z1) * 0.5)
          # and show calculated median
          self.is_median_z = true
        end
      end

      point = collecting_event.verbatim_map_center(delta_z) # hmm

      attributes = {point: point}
      attributes[:by] = self.by if self.by

      if point.nil?
        test_grs = []
      else
        test_grs = GeographicItem::Point.where("point = ST_GeographyFromText('POINT(? ? ?)')", point.x, point.y, point.z)
      end

      if test_grs.empty?
        test_grs = [GeographicItem.new(attributes)]
      end

      self.error_radius = collecting_event.geolocate_uncertainty_in_meters
      self.geographic_item = test_grs.first
    end
  end

  def dwc_georeference_attributes
    h = {}
    super(h)
    h.merge!(
      verbatimLatitude: collecting_event.verbatim_latitude,
      verbatimLongitude: collecting_event.verbatim_longitude,
      coordinateUncertaintyInMeters: error_radius,
      georeferenceSources: "Physical collection object.",
      georeferenceRemarks: "Derived from a instance of TaxonWorks' Georeference::VerbatimData.",
      geodeticDatum: nil  # TODO: check
    )
    h[:georeferenceProtocol] = 'A geospatial point translated from verbatim values recorded on human-readable media (e.g. paper specimen label, field notebook).' if h[:georeferenceProtocol].blank?  
    h
  end

  # @return [Boolean]
  #    true if geographic_item.geo_object is completely contained in collecting_event.geographic_area
  # .default_geographic_item
  def check_obj_within_distance_from_area(distance)
    # case 6
    retval = true
    if collecting_event.present?
      if geographic_item.present? && collecting_event.geographic_area.present?
        if geographic_item.geo_object && collecting_event.geographic_area.default_geographic_item.present?
          retval = geographic_item.st_distance_to_geographic_item(collecting_event.geographic_area.default_geographic_item) <= distance
        end
      end
    end
    retval
  end

  # @return [Boolean] true iff collecting_event contains georeference geographic_item.
  def add_obj_inside_area
    unless check_obj_within_distance_from_area(10000.0)
      errors.add(
        :geographic_item,
        'for georeference is not contained in the geographic area bound to the collecting event')
      errors.add(
        :collecting_event,
        'is assigned a geographic area which does not contain the supplied georeference/geographic item')
    end
  end

end

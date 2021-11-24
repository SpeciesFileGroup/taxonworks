module CollectingEvent::Georeference

  extend ActiveSupport::Concern

  included do
    has_many :georeferences, dependent: :destroy, class_name: '::Georeference', inverse_of: :collecting_event

    has_one :verbatim_data_georeference, class_name: '::Georeference::VerbatimData'

    has_many :error_geographic_items, through: :georeferences, source: :error_geographic_item
    has_many :geographic_items, through: :georeferences # See also all_geographic_items, the union
    has_many :geo_locate_georeferences, class_name: '::Georeference::GeoLocate', dependent: :destroy
    has_many :gpx_georeferences, class_name: '::Georeference::GPX', dependent: :destroy

    accepts_nested_attributes_for :verbatim_data_georeference
    accepts_nested_attributes_for :geo_locate_georeferences
    accepts_nested_attributes_for :gpx_georeferences

    def preferred_georeference
      georeferences.order(:position).first
    end
  end

  # @param [Float] delta_z, will be used to fill in the z coordinate of the point
  # @return [RGeo::Geographic::ProjectedPointImpl, nil]
  #   for the *verbatim* latitude/longitude only
  def verbatim_map_center(delta_z = 0.0)
    retval = nil
    unless verbatim_latitude.blank? or verbatim_longitude.blank?
      lat = Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees(verbatim_latitude.to_s)
      long = Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees(verbatim_longitude.to_s)
      elev = Utilities::Geo.distance_in_meters(verbatim_elevation.to_s)
      delta_z = elev unless elev == 0.0
      retval  = Gis::FACTORY.point(long, lat, delta_z)
    end
    retval
  end

  def latitude
    verbatim_map_center.try(:y)
  end

  def longitude
    verbatim_map_center.try(:x)
  end


  # TODO: Helper method
  # @return [CollectingEvent]
  #   return the next collecting event without a georeference in this collecting events project sort order
  #   1.  verbatim_locality
  #   2.  geography_id
  #   3.  start_date_year
  #   4.  updated_on
  #   5.  id
  def next_without_georeference
    CollectingEvent.not_including(self).
      includes(:georeferences).
      where(project_id: project_id, georeferences: {collecting_event_id: nil}).
      order(:verbatim_locality, :geographic_area_id, :start_date_year, :updated_at, :id).
      first
  end

  # TODO: refactor to nil on no georeference
  def georeference_latitude
    retval = 0.0
    if georeferences.count > 0
      retval = Georeference.where(collecting_event_id: self.id).order(:position).limit(1)[0].latitude.to_f
    end
    retval.round(6)
  end

  # TODO: refactor to nil on no georeference
  def georeference_longitude
    retval = 0.0
    if georeferences.count > 0
      retval = Georeference.where(collecting_event_id: self.id).order(:position).limit(1)[0].longitude.to_f
    end
    retval.round(6)
  end

  # @return [String]
  #   coordinates for centering a Google map
  def verbatim_center_coordinates
    if self.verbatim_latitude.blank? || self.verbatim_longitude.blank?
      'POINT (0.0 0.0 0.0)'
    else
      self.verbatim_map_center.to_s
    end
  end


  # @return [Symbol, nil]
  #   the name of the method that will return an Rgeo object that represent
  #   the "preferred" centroid for this collecing event
  def map_center_method
    return :preferred_georeference if preferred_georeference # => { georeferenceProtocol => ?  }
    return :verbatim_map_center if verbatim_map_center # => { }
    return :geographic_area if geographic_area.try(:has_shape?)
    nil
  end

  # @return [Rgeo::Geographic::ProjectedPointImpl, nil]
  def map_center
    case map_center_method
    when :preferred_georeference
      preferred_georeference.geographic_item.centroid
    when :verbatim_map_center
      verbatim_map_center
    when :geographic_area
      geographic_area.default_geographic_item.geo_object.centroid
    else
      nil
    end
  end

  # @return [Integer]
  # @TODO figure out how to convert verbatim_geolocation_uncertainty in different units (ft, m, km, mi) into meters
  # @TODO: See Utilities::Geo.distance_in_meters(String)
  def get_error_radius
    return nil if verbatim_geolocation_uncertainty.blank?
    return verbatim_geolocation_uncertainty.to_i if is.number?(verbatim_geolocation_uncertainty)
    nil
  end

  # CollectingEvent.select {|d| !(d.verbatim_latitude.nil? || d.verbatim_longitude.nil?)}
  # .select {|ce| ce.georeferences.empty?}
  # @param [Boolean] reference_self
  # @param [Boolean] no_cached
  # @return [Georeference::VerbatimData, false]
  #   generates (creates) a Georeference::VerbatimReference from verbatim_latitude and verbatim_longitude values
  def generate_verbatim_data_georeference(reference_self = false, no_cached: false)
    return false if (verbatim_latitude.nil? || verbatim_longitude.nil?)
    begin
      CollectingEvent.transaction do
        vg_attributes = {collecting_event_id: id.to_s, no_cached: no_cached}
        vg_attributes.merge!(by: self.creator.id, project_id: self.project_id) if reference_self
        a = Georeference::VerbatimData.new(vg_attributes)
        if a.valid?
          a.save
        end
        return a
      end
    rescue
      raise
    end
    false
  end


  # @return [Symbol, nil]
  #   Prioritizes and identifies the source of the latitude/longitude values that
  #   will be calculated for DWCA and primary display
  def dwc_georeference_source
    if !preferred_georeference.nil?
      :georeference
    elsif verbatim_latitude && verbatim_longitude
      :verbatim
    elsif geographic_area && geographic_area.has_shape?
      :geographic_area
    else
      nil
    end
  end


end

# Hooks to Geolocate
module CollectingEvent::GeoLocate

  extend ActiveSupport::Concern

  # rubocop:disable Style/StringHashKeys
  # @return [Hash]
  #   parameters from collecting event that are of use to geolocate
  def geolocate_attributes
    parameters = {
      'country'   => country_name,
      'state'     => state_or_province_name,
      'county'    => county_or_equivalent_name,
      'locality'  => verbatim_locality,
      'Placename' => verbatim_locality,
    }

    focus = case lat_long_source
            when :georeference
              preferred_georeference.geographic_item
            when :geographic_area
              geographic_area.geographic_area_map_focus
            else
              nil
            end

    parameters.merge!(
      'Longitude' => focus.point.x,
      'Latitude'  => focus.point.y
    ) unless focus.nil?
    parameters
  end


  # @return [Hash]
  #    a complete set of params necessary to form a request string
  def geolocate_ui_params
    Georeference::GeoLocate::RequestUI.new(geolocate_attributes).request_params_hash
  end

  # @return [String]
  def geolocate_ui_params_string
    Georeference::GeoLocate::RequestUI.new(geolocate_attributes).request_params_string
  end

  def lat_long_source
    if preferred_georeference
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

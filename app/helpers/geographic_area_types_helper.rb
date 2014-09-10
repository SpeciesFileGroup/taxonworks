module GeographicAreaTypesHelper

  def self.geographic_area_type_tag(geographic_area_type)
    return nil if geographic_area_type.nil?
    geographic_area_type.name
  end

  def geographic_area_type_tag(geographic_area_type)
    GeographicAreaTypesHelper.geographic_area_type_tag(geographic_area_type)
  end

  def geographic_area_type_link(geographic_area_type)
    return nil if geographic_area_type.nil?
    link_to(geographic_area_type.name, geographic_area_type)
  end

  def geographic_area_type_name_select_options
    # an array of the names of GeographicAreaType
    GeographicAreaType.all.map(&:name)
  end

end

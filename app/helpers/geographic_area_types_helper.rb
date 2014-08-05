module GeographicAreaTypesHelper

  def geographic_area_type_tag(geographic_area_type)
    geographic_area_type.name
  end

  def geographic_area_type_link(geographic_area_type)
    return nil if geographic_area_type.nil?
    link_to(geographic_area_type.name, geographic_area_type)
  end

end

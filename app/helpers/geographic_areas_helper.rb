module GeographicAreasHelper

  def geographic_area_link(geographic_area, link_text = nil)
    return nil if geographic_area.nil?
    link_text ||= geographic_area.name
    link_to(link_text, geographic_area_path(geographic_area))
  end

end

module GeographicAreasHelper

  def geographic_area_link(geographic_area, link_text = nil)
    return nil if geographic_area.nil?
    link_text ||= geographic_area.name
    link_to(link_text, geographic_area)
  end

  def geographic_area_link_list(geographic_areas)
    content_tag(:ul) do
      geographic_areas.collect{|a| content_tag(:li, geographic_area_link(a))}.join.html_safe
    end
  end

end

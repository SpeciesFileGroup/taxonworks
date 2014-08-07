module GeographicAreasHelper

  def self.geographic_area_tag(geographic_area)
    return nil if geographic_area.nil?
    geographic_area.name
  end

  def geographic_area_tag(geographic_area)
    GeographicAreasHelper.geographic_area_tag(geographic_area)
  end

  def geographic_area_link(geographic_area, link_text = nil)
    return nil if geographic_area.nil?
    link_text ||= geographic_area.name
    link_to(link_text, geographic_area)
  end

  def geographic_areas_search_form
    render('/geographic_areas/quick_search_form')
  end

  def geographic_areas_link_list_tag(geographic_areas)
    geographic_areas.collect { |ga| link_to(ga.name, ga) }.join(",")
  end

  def geographic_area_link_list(geographic_areas)
    content_tag(:ul) do
      geographic_areas.collect { |a| content_tag(:li, geographic_area_link(a)) }.join.html_safe
    end
  end

end

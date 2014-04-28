module GeographicItemsHelper
  def json_tag(geographic_item)
    geographic_item.to_geo_json.html_safe
  end

  def center_coord_tag(geographic_item)
    json_tag(geographic_item) =~ /(-{0,1}\d+\.{0,1}\d*),(-{0,1}\d+\.{0,1}\d*)/  #get longitude, latitude of first point of geo...item
    "#{$1}, #{$2}".html_safe
  end

  def geographic_item_link(geographic_item, link_text = nil)
    return nil if geographic_item.nil?
    link_text ||= geographic_item.to_param
    link_to(link_text, geographic_item_path(geographic_item))
  end
end

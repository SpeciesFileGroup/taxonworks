module GeographicItemsHelper
  def json_tag(geographic_item)
    retval = geographic_item.to_geo_json_feature.html_safe
    retval
  end

  def center_coord_tag(geographic_item)
    geographic_item.center_coords.join(', ')
  end

  def geographic_item_link(geographic_item, link_text = nil)
    return nil if geographic_item.nil?
    link_text ||= geographic_item.to_param
    link_to(link_text, geographic_item_path(geographic_item), data: {no_turbolink: true})
  end

  def geographic_item_links(geographic_items)
    return content_tag(:em, 'none') if geographic_items.count == 0
    geographic_items.collect { |a| geographic_item_link(a) }.join(", ").html_safe
  end

  # A little ugly
  def geographic_item_parent_nav_links(geographic_item)
    content_tag(:div,
                geographic_item.parents_through_geographic_areas.collect { |k, v| [
                  content_tag(:ul, v.collect { |b|
                    content_tag(:li, geographic_item_link(b, k.name)) }.join.html_safe)] }.flatten.join.html_safe)
  end


end

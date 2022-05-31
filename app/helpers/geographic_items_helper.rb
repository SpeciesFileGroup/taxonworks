module GeographicItemsHelper

  def geographic_item_tag(geographic_item)
    return nil if geographic_item.nil?
    geographic_item.to_param 
  end

  def json_tag(geographic_item)
    retval = geographic_item.to_geo_json_feature.to_json
    retval
  end

  def center_coord_tag(geographic_item)
    geographic_item.center_coords.join(', ')
  end

  def geographic_item_link(geographic_item, link_text = nil)
    return nil if geographic_item.nil?
    link_text ||= geographic_item.to_param
    link_to(link_text, geographic_item_path(geographic_item), data: {turbolinks: false})
  end

  def geographic_item_links(geographic_items)
    return content_tag(:em, 'none') if geographic_items.count == 0
    geographic_items.collect { |a| geographic_item_link(a) }.join(', ').html_safe
  end

  def geographic_item_parent_nav_links(geographic_item)
    data = {} 
    geographic_item.parent_geographic_areas.each do |a|
      data[a] = a.geographic_items
    end 

    content_tag(:div,
                data.collect { |k, v| [
                  content_tag(:ul, v.collect { |b|
                    content_tag(:li, geographic_item_link(b, k.name)) }.join.html_safe)
                ] }.flatten.join.html_safe)
  end

  def children_through_geographic_areas_links(geographic_item)
    data = {}
    geographic_item.geographic_areas.each do |a| 
      a.children.collect{ |c|
        data[c] = c.geographic_items.all
      }
    end 

    links = []
    data.each do |k,v|
      next if v.nil?
      links += v.collect{ |i| geographic_item_link(i, k.name) }
    end 
    links.join(', ').html_safe
  end

end

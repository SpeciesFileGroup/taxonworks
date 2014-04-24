module GeographicItemsHelper
  def json_tag(geographic_item)
    geographic_item.to_geo_json.html_safe
  end
end

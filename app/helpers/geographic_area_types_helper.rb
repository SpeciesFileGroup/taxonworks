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

  def geographic_area_type_name_select_options(selected)
    # You could just render this as is, instead of wrapping it in a helper:
    options_from_collection_for_select(GeographicAreaType.all.order(:name),
                                       :id,
                                       :name,
                                       (selected.nil? ? GeographicAreaType.where(name: 'Unknown').first.id : selected))
  end

end

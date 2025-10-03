module TypeMaterialsHelper

  def type_material_tag(type_material)
    return nil if type_material.nil?
    [
      type_material.type_type,
full_original_taxon_name_tag(type_material.protonym)
      ].compact.join(' of ')
  end

  def type_material_link(type_material)
    return nil if type_material.nil?
    link_to(type_material_tag(type_material).html_safe, type_material)
  end

  def label_for_type_material(type_material)
    return nil if type_material.nil?
    [type_material.type_type, full_original_taxon_name_label(type_material.protonym)].compact.join(' of ')
  end

  # @return [GeoJson feature]
  # @param base [Boolean]
  #
  def type_material_to_geo_json_feature(type_material, base = true)
    return nil if type_material.nil?
    if a = collection_object_to_geo_json_feature(type_material.collection_object, false)
      l = label_for_type_material(type_material)
      a['properties']['target'] = {
        'type' => 'TypeMaterial',
        'id' => type_material.id,
        'label' => l
      }
      if base
        a['properties']['base'] = {
          'type' => 'TypeMaterial',
          'id' => type_material.id,
          'label' => l
        }
      end
      a
    else
      nil
    end
  end

  def type_materials_search_form
    render('/type_materials/quick_search_form')
  end

  def options_for_type_type_select
    options_for_select((TypeMaterial::ICZN_TYPES.keys + TypeMaterial::ICN_TYPES.keys).uniq.sort, selected: 'holotype')
  end

  # !! Only (currently) meaningful for ICN and ICZN - returns true for all other
  # codes !!
  def type_material_is_primary_type(type_material)
    (type_material.protonym.nomenclatural_code == :iczn &&
      TypeMaterial::ICZN_PRIMARY_TYPES.include?(type_material.type_type)) ||
    (type_material.protonym.nomenclatural_code == :icn &&
      TypeMaterial::ICN_PRIMARY_TYPES.include?(type_material.type_type)) ||
    ![:icn, :iczn].include?(type_material.protonym.nomenclatural_code)
  end

end

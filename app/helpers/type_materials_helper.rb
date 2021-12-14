module TypeMaterialsHelper

  def type_material_tag(type_material)
    return nil if type_material.nil?
    [type_material.type_type, 'of', full_original_taxon_name_tag(type_material.protonym)].compact.join(' ')
  end

  def type_material_link(type_material)
    return nil if type_material.nil?
    link_to(type_material_tag(type_material).html_safe, type_material)
  end

  def label_for_type_material(type_material)
    return nil if type_material.nil?
    type_material.type_type + ' of ' + full_original_taxon_name_label(type_material.protonym)
  end

  def type_materials_search_form
    render('/type_materials/quick_search_form')
  end

  def options_for_type_type_select
    options_for_select((TypeMaterial::ICZN_TYPES.keys + TypeMaterial::ICN_TYPES.keys).uniq.sort, selected: 'holotype')
  end

end

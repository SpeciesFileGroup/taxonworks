module TypeMaterialsHelper

  def self.type_material_tag(type_material)
    # type_material.cached.blank? ? 'CACHED VALUE NOT BUILT - CONTACT ADMIN' : type_material.cached
    return nil if type_material.nil?
    type_material.verbatim_locality
  end

  def type_material_tag(type_material)
    TypeMaterialsHelper.type_material_tag(type_material)
  end

  def type_material_link(type_material)
    return nil if type_material.nil?
    link_to(type_material_tag(type_material).html_safe, type_material)
  end

  def type_materials_search_form
    render('/type_materials/quick_search_form')
  end

end

json.type_materials_catalog_labels @type_materials.map { |t|
  {
    id: t.id,
    protonym_id: t.protonym_id,
    taxon_name: full_original_taxon_name_label(t.protonym),
    is_valid: t.protonym.cached_is_valid,
    type_type: t.type_type,
    label: type_material_catalog_label(t)
  }
}

json.type_materials_catalog_labels @otu.type_materials.map { |t| {type_type: t.type_type, label: type_material_catalog_label(t) } }

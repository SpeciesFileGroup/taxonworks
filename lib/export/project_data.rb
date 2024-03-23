module ::Export::ProjectData

  # When adding a new table be sure to check there is nothing different compared to existing ones.
  HIERARCHIES = [
    ['container_item_hierarchies', 'container_items'],
    ['lead_hierarchies', 'leads'],
    ['geographic_area_hierarchies', 'geographic_areas'],
    ['taxon_name_hierarchies', 'taxon_names']
  ].freeze

  SPECIAL_TABLES = %w{spatial_ref_sys project users versions delayed_jobs imports}.freeze
end

module BatchLoad 

  # Defines columns which may be used to identify existing instances on a per class basis, 
  # logic is in BatchLoad::ColumnResolver
  COLUMNS = {
    otu: %w{otu_name otu_id taxon_name_id taxon_name},
    geographic_area: %w{geographic_area_name country state county},
    source: %w{geographic_area_name country state :county} 
  }.freeze

end

# require_dependency Rails.root + 'lib/batch_load/import'
# require_dependency Rails.root + 'lib/batch_load/import/collection_objects'
# require_dependency Rails.root + 'lib/batch_load/import/taxon_names'

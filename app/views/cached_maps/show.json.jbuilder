
json.extract! @cached_map, :id, :reference_count, :created_at, :cached_map_type

json.merge! cached_map_sync_metadata(@cached_map)

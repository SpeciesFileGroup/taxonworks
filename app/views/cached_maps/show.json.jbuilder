
json.extract @cached_map, :id, :reference_count, :updated_at, :cached_map_type
json.synced @cached_map.synced?
json.created_at @cached_map.created_at
json.latest_cached_map_item_created_at @cached_map.latest_cached_map_item.created_at
json.cached_map_item_reference_total @cached_map.cached_map_items_reference_total
json.cached_map_item_reference_total @cached_map.cached_map_items_reference_total


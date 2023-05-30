module CachedMapsHelper

  def cached_map_sync_metadata(cached_map)
    return {} unless cached_map.present?

    i = cached_map.latest_cached_map_item
    a = cached_map.updated_at
    b = i.created_at

    c = cached_map.synced?

    h = {
     updated_at: a,
     latest_cached_map_item_created_at: b,
     synced: c,
     cached_map_item_reference_total: cached_map.cached_map_items_reference_total
    }

    unless !c
      h[:time_between_data_and_sync] = distance_of_time_in_words(a,b)
      h[:time_between_data_and_now] = distance_of_time_in_words(b, DateTime.now)
    end
    h
   end

end

module CachedMapsHelper

  def cached_map_sync_metadata(cached_map)
    return {} unless cached_map.present?


    o = Otu.find(cached_map.otu_id)

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

    tn = ::Queries::TaxonName::Filter.new(taxon_name_id: o.taxon_name_id, descendants: true)
    otus = ::Queries::Otu::Filter.new(taxon_name_id: o.taxon_name_id, descendants: true)
    cos = ::Queries::CollectionObject::Filter.new(taxon_name_id: o.taxon_name_id, descendants: true)
    ads = ::Queries::AssertedDistribution::Filter.new(taxon_name_id: o.taxon_name_id, descendants: true)
    g = Georeference.joins(collecting_event: [:collection_objects]).where(collection_objects: cos.all)

    h[:source_scope] = {
      taxon_names: tn.all.count,
      otus: otus.all.count,
      collection_objects: cos.all.count,
      georeferences: g.count,
      unregistered_georeferences: g.where.missing(:cached_map_register).count, # TODO: needs helper method scoping to MapType when > type added
      asserted_distributions: ads.all.count,
      unregistered_asserted_distributions: ads.all.where.missing(:cached_map_register).count, # TODO: see above. Note that these could be because they have no shape!
    }

    h
  end

end

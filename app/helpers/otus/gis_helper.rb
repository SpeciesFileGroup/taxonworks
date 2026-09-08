module Otus::GisHelper

  # @return Hash
  #   A GeoJSON collection of distribution data in x parts
  #     need a `to_geo_json` for each object
  #
  #      :asserted_distributions
  #         with shape
  #         without shapes
  #      :collection_objects
  #           with georeferences
  #           with GeographicAreas
  #      :type material
  #           with georeferences
  #           with GeographicAreas
  # TODO:
  #
  #  * make properties universal
  #    type: 'Model',
  #    id: id,
  #    label: <label>
  # * merge origin_otu_id: id to reference coordinate OTUs
  #
  #  target:
  #    type: Otu
  #    label:
  #    id
  #
  #  base:   # one level above target (or one level below shape?!)
  #    type:
  #    id:
  #
  #  shape: # Either GeographicArea or Georeference
  #     type
  #     id
  #
  def otu_distribution(otu, children = true, cutoff = 200)
    return {} if otu.nil?
    otus = if children
      otu.coordinate_otus_with_children
    else
      Otu.coordinate_otus(otu.id)
    end

    h = geojson_for_otu(otu)

    if otu.taxon_name && otu.taxon_name.is_protonym? && !otu.taxon_name.is_species_rank?
      add_aggregate_geo_json(otu, h)
    else
      otus = if children
              otu.coordinate_otus_with_children
            else
              Otu.coordinate_otus(otu.id)
            end

      # Batch-load everything the downstream helpers touch.
      otus = otus.includes(
        :taxon_name,
        current_field_occurrences: [
          :identifiers,
          { collecting_event: [ :georeferences, :geographic_area, :geographic_items ] }
        ],
        current_collection_objects: [
          :identifiers,
          { collecting_event: [ :georeferences, :geographic_area, :geographic_items ] }
        ],
        asserted_distributions: { asserted_distribution_shape: :geographic_items },
        type_materials: [
          { collection_object: [
              :identifiers,
              { collecting_event: [ :georeferences, :geographic_area, :geographic_items ] }
            ] }
        ]
      )

      seen_shapes = {
        field_occurrences: {},
        collection_objects: {},
        asserted_distributions: {},
        type_materials: {}
      }

      otus.each do |o|
        add_distribution_geo_json(o, h, seen_shapes)
      end
    end

    h
  end

  # @return [Hash]
  #   GeoJSON FeatureCollection of absent FieldOccurrences and AssertedDistributions
  #   for the OTU, its coordinate OTUs, and ancestor taxon names (traversed via
  #   TaxonNameHierarchies).
  # @param descendants [Boolean] when true, also include direct absents from
  #   descendant OTUs. Off by default: a descendant's absence does not propagate
  #   up to the OTU, and a sibling descendant's presence in the same region may
  #   contradict it. Use only when the caller wants a clade-wide visualization.
  def otu_distribution_is_absent(otu, descendants: false)
    return {} if otu.nil?

    h = geojson_for_otu(otu)
    seen_shapes = {
      field_occurrences: {},
      asserted_distributions: {}
    }

    otus = descendants ? otu.coordinate_otus_with_children : Otu.coordinate_otus(otu.id)

    otus.each do |o|
      t = geojson_target_for_otu(o)

      o.absent_and_ancestor_absent_field_occurrences.each do |f|
        shape_key = f.collecting_event&.geo_json_shape_key
        g = build_geo_json_feature_deduped(seen_shapes[:field_occurrences], shape_key) do |skip_geometry|
          field_occurrence_to_geo_json_feature(f, skip_geometry:)
        end
        next unless g
        g['properties']['target'] = t
        h['features'].push g
      end

      o.absent_and_ancestor_absent_asserted_distributions.each do |a|
        shape_key = [a.asserted_distribution_shape_type, a.asserted_distribution_shape_id]
        g = build_geo_json_feature_deduped(seen_shapes[:asserted_distributions], shape_key) do |skip_geometry|
          asserted_distribution_to_geo_json_feature(a, skip_geometry:)
        end
        next unless g
        g['properties']['target'] = t
        h['features'].push g
      end
    end

    h
  end

  def geojson_for_otu(otu)
    {
      'type' => 'FeatureCollection',
      'features' => [],
      'properties' => {
        'target' => geojson_target_for_otu(otu)
      }
    }
  end

  def geojson_target_for_otu(otu)
    {
      'id' => otu.id,
      'label' => label_for_otu(otu),
      'type' => 'Otu'
    }
  end

  def add_aggregate_geo_json(otu, target)
    h = target

    if g = aggregate_geo_json(otu, h)
      g['properties'] = {'aggregate': true}
      g['properties']['target'] = geojson_target_for_otu(otu)

      h['features'].push g
    end

    h
  end

  # NOT USED
  # Caching the cached map
  def otu_cached_map(otu, target, cached_map_type = 'CachedMapItem::WebLevel1', cache = true, force = false)
    r = nil
    if force
      r = aggregate_geo_json(otu, target, cached_map_type)
    else
      # Check for map

      # TODO: extend with synced check
      if a = CachedMap.where(project_id: sessions_current_project_id).where(otu_id: otu.id, cached_map_type:  )
      end
    end
  end

  # TODO: cleanup
  def aggregate_geo_json(otu, target, cached_map_type = 'CachedMapItem::WebLevel1')
    h = target

    if gj = otu.cached_map_geo_json(cached_map_type)

      i =
        {
          **gj,
          # 'type' => gj['type'],  # 'Feature',

          'properties' => {
            'base' => geojson_target_for_otu(otu),
            #     'shape' => {
            #       'type' => cached_map_type,
            #       'id' => 99999 }, # was nil
            'updated_at' => 'foo' # last updated at on CachedMapItem scope, possibly
          }
        }

      if gj.keys.include?('coordinates')
        i['coordinates'] = gj['coordinates'] # was 'coordinates' TODO: might not work
      elsif gj.keys.include?('geometries')
        i['geometries'] = gj['geometries'] # was 'coordinates' TODO: might not work
      end

      i

    else
      nil
    end

  end

  def add_distribution_geo_json(otu, target, seen_shapes = nil)
    h = target
    o = otu

    # internal target
    t = geojson_target_for_otu(otu)

    o.current_field_occurrences.where(is_absent: [nil, false]).each do |f|
      shape_key = seen_shapes && f.collecting_event&.geo_json_shape_key
      g = build_geo_json_feature_deduped(seen_shapes&.fetch(:field_occurrences), shape_key) do |skip_geometry|
        field_occurrence_to_geo_json_feature(f, skip_geometry:)
      end
      next unless g
      g['properties']['target'] = t
      h['features'].push g
    end

    o.current_collection_objects.each do |c|
      shape_key = seen_shapes && c.collecting_event&.geo_json_shape_key
      g = build_geo_json_feature_deduped(seen_shapes&.fetch(:collection_objects), shape_key) do |skip_geometry|
        collection_object_to_geo_json_feature(c, skip_geometry:)
      end
      next unless g
      g['properties']['target'] = t
      h['features'].push g
    end

    o.asserted_distributions.without_is_absent.each do |a|
      shape_key = seen_shapes && [a.asserted_distribution_shape_type, a.asserted_distribution_shape_id]
      g = build_geo_json_feature_deduped(seen_shapes&.fetch(:asserted_distributions), shape_key) do |skip_geometry|
        asserted_distribution_to_geo_json_feature(a, skip_geometry:)
      end
      next unless g
      g['properties']['target'] = t
      h['features'].push g
    end

    ba_ids = ::Queries::BiologicalAssociation::Filter.new(otu_query: { otu_id: [o.id] }).all.pluck(:id)
    unless ba_ids.empty?
      ::AssertedDistribution
        .where(
          asserted_distribution_object_type: 'BiologicalAssociation',
          asserted_distribution_object_id: ba_ids
        )
        .without_is_absent
        .each do |a|
          shape_key = seen_shapes && [a.asserted_distribution_shape_type, a.asserted_distribution_shape_id]
          g = build_geo_json_feature_deduped(seen_shapes&.fetch(:asserted_distributions), shape_key) do |skip_geometry|
            asserted_distribution_to_geo_json_feature(a, skip_geometry:)
          end
          next unless g
          g['properties']['target'] = t
          h['features'].push g
        end

      bag_ids = ::BiologicalAssociationsGraph
        .joins(:biological_associations_biological_associations_graphs)
        .where(biological_associations_biological_associations_graphs: { biological_association_id: ba_ids })
        .select(:id)

      unless bag_ids.empty?
        ::AssertedDistribution
          .where(
            asserted_distribution_object_type: 'BiologicalAssociationsGraph',
            asserted_distribution_object_id: bag_ids
          )
          .without_is_absent
          .each do |a|
            shape_key = seen_shapes && [a.asserted_distribution_shape_type, a.asserted_distribution_shape_id]
            g = build_geo_json_feature_deduped(seen_shapes&.fetch(:asserted_distributions), shape_key) do |skip_geometry|
              asserted_distribution_to_geo_json_feature(a, skip_geometry:)
            end
            next unless g
            g['properties']['target'] = t
            h['features'].push g
          end
      end
    end

    [
      [o.depictions, 'Depiction', :depiction_object_id],
      [o.conveyances, 'Conveyance', :conveyance_object_id],
      [o.observations, 'Observation', :observation_object_id],
    ].each do |related_records, object_type, _id_method|
      related_ids = related_records.map(&:id)
      next if related_ids.empty?

      ::AssertedDistribution
        .where(
          asserted_distribution_object_type: object_type,
          asserted_distribution_object_id: related_ids
        )
        .without_is_absent
        .each do |a|
          shape_key = seen_shapes && [a.asserted_distribution_shape_type, a.asserted_distribution_shape_id]
          g = build_geo_json_feature_deduped(seen_shapes&.fetch(:asserted_distributions), shape_key) do |skip_geometry|
            asserted_distribution_to_geo_json_feature(a, skip_geometry:)
          end
          next unless g
          g['properties']['target'] = t
          h['features'].push g
        end
    end

    o.type_materials.includes(:protonym).each do |e|
      next unless type_material_is_primary_type(e) && o.taxon_name.cached_is_valid

      shape_key = seen_shapes && e.collection_object&.collecting_event&.geo_json_shape_key
      g = build_geo_json_feature_deduped(seen_shapes&.fetch(:type_materials), shape_key) do |skip_geometry|
        type_material_to_geo_json_feature(e, skip_geometry:)
      end
      next unless g
      g['properties']['target'] = t
      h['features'].push g
    end

    h
  end

  private

  # Yields once with skip_geometry true or false depending on whether +shape_key+
  # [shape_type, shape_id] has already been recorded in +seen+.
  #
  # First occurrence of a shape: yields skip_geometry=false (full geometry fetched).
  #   The shape is recorded in +seen+ only if the block returns a non-nil feature,
  #   so shapes that produce no feature (e.g. no geographic item) are never marked seen.
  # Subsequent occurrences: yields skip_geometry=true (geometry skipped, nil in feature).
  #
  # When +seen+ or +shape_key+ is nil (deduplication disabled or no shape available),
  # yields skip_geometry=false unconditionally.
  def build_geo_json_feature_deduped(seen, shape_key)
    if seen.nil? || shape_key.nil? || shape_key.first.nil?
      return yield(false)
    end

    key = "#{shape_key[0]}_#{shape_key[1]}"
    if seen.key?(key)
      yield(true)
    else
      g = yield(false)
      seen[key] = true if g
      g
    end
  end

end

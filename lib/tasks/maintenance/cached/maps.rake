namespace :tw do
  namespace :maintenance do
    namespace :cached do

      # Everything is wiped
      #   We build cached_map_item_tranlsations for every observed unique geographic_item
      #      We find the unique geographic_items from ADs
      #      We find the unique geographic_items from GZs
      #
      #
      #   Now we LOOP NE states!!! (not georeferences)
      #     We find all point Georeferences in each state 
      #        Register translations en-masse
      #     We find all non-point Georeferences
      #       ONLY HERE SHOULD WE DO FANCY GEO MATH
      #       Register translations en-masse
      #
      #   At this point there should be _no need for any spatial calculations (until we make the map itself)_
      # 
      #  !! Now we sanity check and ensure that all GIs are translated, so that we never hit spatial calculations downstream. 
      #       
      #  Now we should be able to loop OTUs and simply register IDs... 
      # 

      # !! These tasks only build new records. They will not synchronize/refresh existing records. !!
      #
      # If starting from nothing, or to start completely anew:
      #
      #  rake tw:maintenance:cached:maps:everything_from_clean_slate cached_rebuild_processes=4
      #
      #  The index can be built all at once, appending when not present, with:
      #
      #  rake tw:maintenance:cached:maps:full_index cached_rebuild_processes=4
      #
      # This fires tasks that can be run individually, and idempotently, though the last ("label") should be run
      # at the completion of of the cache build:
      #
      # rake tw:maintenance:cached:maps:parallel_create_cached_map_item_translations_from_asserted_distributions cached_rebuild_processes=4
      # rake tw:maintenance:cached:maps:parallel_create_cached_map_from_asserted_distributions cached_rebuild_processes=4
      #
      # Either of these:
      # rake tw:maintenance:cached:maps:parallel_create_cached_map_from_georeferences cached_rebuild_processes=4
      # rake tw:maintenance:cached:maps:parallel_create_cached_map_from_georeferences_by_area cached_rebuild_processes=4
      #
      # rake tw:maintenance:cached:maps:parallel_label_cached_map_items cached_rebuild_processes=4
      #
      # You can target a build for a specific OTU with:
      #
      #   rake tw:maintenance:cached:maps:parallel_create_cached_map_for_otu otu_id=123 cached_rebuild_processes=4
      #
      # You can destroy *everything* related to CachedMap<X> with
      #
      #   rake tw:maintenance:cached:maps:destroy_all
      #
      # You shouldn't do that likely though, the Translation table is useful, so do:
      #
      #   rake tw:maintenance:cached:maps:destroy_index
      #
      # Other helpfull bits when debugging:
      #
      # In the console you can erase the cached CacheMap (this does not destroy the underlying index, only the data
      # used in subsequent calls to return the aggregate map) with:
      #
      # ```
      # CachedMap.delete_all
      # ```
      #
      namespace :maps do

        desc 'destroy all cached map references'
        task destroy_all: [:environment] do |t|
          puts 'Destroying everything related to cached maps'
          CachedMap.delete_all
          CachedMapRegister.delete_all
          CachedMapItemTranslation.delete_all
          CachedMapItem.delete_all
          puts 'Done.'
        end

        desc 'destroy all cached map references *except* the translation table'
        task destroy_index: [:environment] do |t|
          puts 'Destroying CachedMap index except translations'
          CachedMap.delete_all
          CachedMapRegister.delete_all
          CachedMapItem.delete_all
          puts 'Done.'
        end

        desc 'perform a full index run'
        task full_index: [
          :parallel_create_cached_map_item_translations_from_asserted_distributions,
          :parallel_create_cached_map_from_asserted_distributions,
          :parallel_create_cached_map_from_georeferences,
          # :parallel_create_cached_map_from_georeferences_by_area
        ] do |t|
          puts 'Done full index.'
        end

        desc 'perform a full index run, then label'
        task everything_from_clean_slate: [
          :destroy_all,
          :full_index,
          :parallel_label_cached_map_items,
        ] do |t|
          puts 'Done everything.'
        end

        desc 'label cached_map_items'
        task parallel_label_cached_map_items: [:environment] do |t|

          cached_rebuild_processes = ENV['cached_rebuild_processes'] ? ENV['cached_rebuild_processes'].to_i : 4

          items = CachedMapItem.select(:geographic_item_id).where(
            level0_geographic_name: nil,
            level1_geographic_name: nil,
            level2_geographic_name: nil
          ).distinct

          puts "Labelling #{items.count} CachedMapItems."

          Parallel.each(items.each, progress: 'labelling_geographic_items', in_processes: cached_rebuild_processes ) do |o|

            h = CachedMapItem.cached_map_name_hierarchy(o.geographic_item_id)

            z = CachedMapItem.where(geographic_item_id: o.geographic_item_id)
              .where(untranslated: [nil, false])

            #puts 'Size: ' + z.size.to_s

            z.update_all(
              level0_geographic_name: h[:country],
              level1_geographic_name: h[:state],
              level2_geographic_name: h[:county]
            )

            #puts o.geographic_item_id
            #puts h
          end
          puts 'Done labelling cached map items.'
        end

        # NOT considered a batch = true method (labels as it builds)
        desc 'build CachedMapItems for an OTU, idempotent'
        task parallel_create_cached_map_for_otu: [:environment] do |t|

          cached_rebuild_processes = ENV['cached_rebuild_processes'] ? ENV['cached_rebuild_processes'].to_i : 4

          otu = Otu.find(ENV['otu_id'])

          puts "Building for #{otu.name}: #{otu.taxon_name&.cached || otu.name} ..."

          if otu.taxon_name_id
            otus = Otu.descendant_of_taxon_name(otu.taxon_name_id)
          else
            otus = Otu.where(id: otu.id)
          end

          puts "#{otus.count} total OTUs."

          Parallel.each(otus.find_each, progress: 'build_cached_map_for_otu', in_processes: cached_rebuild_processes ) do |o|
            o.collecting_events.each do |ce|

              # !! All georeferences, not just one
              ce.georeferences.where.missing(:cached_map_register).each do |g|

                begin
                  CachedMapItem.transaction do
                    reconnected ||= Georeference.connection.reconnect! || true # https://github.com/grosser/parallel
                    g.send(:create_cached_map_items, true)
                  end
                  true
                rescue => exception
                  puts " FAILED #{exception} #{g.id}"
                end

              end
            end

            o.asserted_distributions.where.missing(:cached_map_register).each do |ad|
              begin
                CachedMapItem.transaction do
                  reconnected ||= AssertedDistribution.connection.reconnect! || true # https://github.com/grosser/parallel
                  ad.send(:create_cached_map_items, true)
                end
                true
              rescue => exception
                puts " FAILED #{exception} #{ad.id}"
              end
            end
          end
          puts 'Done.'
        end

        desc 'build CachedMapItems for Georeferences that do not have them, idempotent'
        task parallel_create_cached_map_from_georeferences: [:environment] do |t|
          # TODO: this doesn't currently account for FOs
          q = Georeference.joins(:otus).where.missing(:cached_map_register).distinct

          cached_rebuild_processes = ENV['cached_rebuild_processes'] ? ENV['cached_rebuild_processes'].to_i : 4
          cached_rebuild_batch_size = ENV['cached_rebuild_batch_size'] ? ENV['cached_rebuild_batch_size'].to_i : 2000

          # Pluck IDs only - avoids Parallel.each calling .to_a on the
          # enumerator and materializing all AR objects in the parent process.
          ids = q.pluck(:id)
          puts "Caching #{ids.size} georeferences records."

          slices = ids.each_slice(cached_rebuild_batch_size).to_a

          Parallel.each(slices, progress: 'build_cached_map_from_georeferences',
            in_processes: cached_rebuild_processes ) do |slice_ids|
            registrations = []
            begin
              reconnected ||= Georeference.connection.reconnect! || true # https://github.com/grosser/parallel

              # Pre-compute OTU context for the slice in 1 query instead of
              # 2 queries per georeference (N+1 elimination).
              # Chain: georeference -> collecting_event -> collection_objects
              #        -> taxon_determinations (position 1) -> otu
              otu_rows = Otu
                .joins(collection_objects: [:collecting_event])
                .joins(:taxon_determinations)
                .where(taxon_determinations: { position: 1 })
                .where(collecting_events: {
                  id: Georeference.where(id: slice_ids).select(:collecting_event_id)
                })
                .distinct
                .pluck(
                  'collecting_events.id',
                  'otus.id',
                  'otus.taxon_name_id'
                )

              # Group by collecting_event_id since georeference belongs_to
              # collecting_event - hash lookup replaces per-record queries.
              # Only include OTUs that have a taxon_name_id — OTUs without
              # taxon names have no hierarchy and don't contribute to cached maps.
              ce_otu_lookup = {}
              otu_rows.each do |ce_id, otu_id, taxon_name_id|
                next unless taxon_name_id
                (ce_otu_lookup[ce_id] ||= []) << otu_id
              end

              Georeference.where(id: slice_ids).each do |g|
                otu_ids = ce_otu_lookup[g.collecting_event_id]
                next unless otu_ids
                g.send(:create_cached_map_items, true,
                  context: { otu_id: otu_ids },
                  skip_register: true, register_queue: registrations)
              end
              
              CachedMapRegister.insert_all(registrations) if registrations.present?
              true
            rescue => exception
              puts " FAILED #{exception}"
            end
            true
          end

          puts 'Done.'
        end

        desc 'build CachedMapItems for AssertedDistributions that do not have them'
        task parallel_create_cached_map_from_asserted_distributions: [:environment] do |t|
          default_gagi_sql = GeographicAreasGeographicItem.default_geographic_item_data_sql

          q_ga = AssertedDistribution
            .with_otus
            .without_is_absent
            .where(asserted_distribution_shape_type: 'GeographicArea')
            .where.missing(:cached_map_register)
            .joins("JOIN geographic_areas ga ON asserted_distributions.asserted_distribution_shape_id = ga.id")
            .joins("JOIN (#{default_gagi_sql}) default_gagi ON default_gagi.geographic_area_id = ga.id")
            .reselect(
              'asserted_distributions.id, ' \
              'asserted_distributions.project_id, ' \
              'asserted_distributions.is_absent, ' \
              'asserted_distributions.asserted_distribution_object_type, ' \
              'asserted_distributions.asserted_distribution_object_id, ' \
              'asserted_distributions.asserted_distribution_shape_type, ' \
              'otus.id AS otu_id, ' \
              'otus.taxon_name_id AS otu_taxon_name_id, ' \
              'default_gagi.geographic_item_id AS default_geographic_item_id'
            )

          q_gz = AssertedDistribution
            .with_otus
            .without_is_absent
            .where(asserted_distribution_shape_type: 'Gazetteer')
            .where.missing(:cached_map_register)
            .joins("JOIN gazetteers ON asserted_distributions.asserted_distribution_shape_id = gazetteers.id")
            .reselect(
              'asserted_distributions.id, ' \
              'asserted_distributions.project_id, ' \
              'asserted_distributions.is_absent, ' \
              'asserted_distributions.asserted_distribution_object_type, ' \
              'asserted_distributions.asserted_distribution_object_id, ' \
              'asserted_distributions.asserted_distribution_shape_type, ' \
              'otus.id AS otu_id, ' \
              'otus.taxon_name_id AS otu_taxon_name_id, ' \
              'gazetteers.geographic_item_id AS default_geographic_item_id'
            )

          cached_rebuild_processes = ENV['cached_rebuild_processes'] ? ENV['cached_rebuild_processes'].to_i : 4
          cached_rebuild_batch_size = ENV['cached_rebuild_batch_size'] ? ENV['cached_rebuild_batch_size'].to_i : 10000

          # Pluck IDs only - avoids Parallel.each calling .to_a on the
          # enumerator and materializing all AR objects in the parent process.
          ga_ids = q_ga.pluck('asserted_distributions.id')
          gz_ids = q_gz.pluck('asserted_distributions.id')
          puts "Caching #{ga_ids.size} GA + #{gz_ids.size} GZ = #{ga_ids.size + gz_ids.size} AssertedDistribution records."

          [
            [ga_ids, q_ga, 'build_cached_map_from_asserted_distributions GA'],
            [gz_ids, q_gz, 'build_cached_map_from_asserted_distributions GZ']
          ].each do |ids, q, progress|
            slices = ids.each_slice(cached_rebuild_batch_size).to_a

            Parallel.each(slices, progress:,
              in_processes: cached_rebuild_processes ) do |slice_ids|
              registrations = []
              begin
                reconnected ||= AssertedDistribution.connection.reconnect! || true # https://github.com/grosser/parallel
                q.where('asserted_distributions.id': slice_ids).each do |ad|
                  context = {
                    geographic_item_id: ad.default_geographic_item_id,
                    otu_id: ad.otu_id,
                    otu_taxon_name_id: ad.otu_taxon_name_id,
                    geographic_area_based: ad.asserted_distribution_shape_type == 'GeographicArea'
                  }
                  ad.send(:create_cached_map_items, true, context: context,
                    skip_register: true, register_queue: registrations)
                end

                CachedMapRegister.insert_all(registrations) if registrations.present?
                true
              rescue => exception
                puts " FAILED #{exception}"
              end
              true
            end
          end

          puts 'Done.'
        end

        desc 'prebuild CachedMapItemTranslations, NOT idempotent'
        task parallel_create_cached_map_item_translations_from_asserted_distributions: [:environment] do |t|
          cached_rebuild_processes = ENV['cached_rebuild_processes'] ? ENV['cached_rebuild_processes'].to_i : 4

          task_start = Time.current

          # ids = GeographicAreasGeographicItem.where(geographic_area: GeographicArea.joins(:asserted_distributions))
          #        .where.missing(:cached_map_item_translations)
          #        .default_geographic_item_data   # This does not do what we want it do as a join
          #        .select(:geographic_item_id)
          #        .distinct
          #        .pluck(:geographic_item_id)

          puts "Preparing... #{task_start}"

          ids_out = CachedMapItemTranslation.select(:geographic_item_id).distinct
          default_gagi_sql = GeographicAreasGeographicItem.default_geographic_item_data_sql

          ga_gi_ids = GeographicArea.joins(:asserted_distributions)
            .joins("JOIN (#{default_gagi_sql}) default_gagi ON default_gagi.geographic_area_id = geographic_areas.id")
            .select('DISTINCT default_gagi.geographic_item_id AS id')

          gz_gi_ids = Gazetteer.joins(:asserted_distributions)
            .select('DISTINCT gazetteers.geographic_item_id AS id')

          # .count on SELECT ... AS id produces invalid COUNT(... AS id),
          # so unscope and count the raw column.
          ga_total = ga_gi_ids.unscope(:select).count('DISTINCT default_gagi.geographic_item_id')
          ga_done = ga_gi_ids.where(id: ids_out).unscope(:select).count('DISTINCT default_gagi.geographic_item_id')
          puts "Total GeographicArea-based geographic items to translate: #{ga_total}"
          puts "GeographicArea-based geographic items already done: #{ga_done}"

          gz_total = gz_gi_ids.unscope(:select).count('DISTINCT gazetteers.geographic_item_id')
          gz_done = gz_gi_ids.where(id: ids_out).unscope(:select).count('DISTINCT gazetteers.geographic_item_id')
          puts "Total Gazetteer-based geographic items to translate: #{gz_total}"
          puts "Gazetteer-based geographic items already done: #{gz_done}"

          ga_missing_gi_ids = ga_gi_ids.where.not(id: ids_out).map(&:id)
          gz_missing_gi_ids = gz_gi_ids.where.not(id: ids_out).map(&:id)

          puts "Processing #{ga_missing_gi_ids.size} GeographicArea-based geographic items"
          puts "Processing #{gz_missing_gi_ids.size} Gazetteer-based geographic items"

          precomputed_data_origin_ids = {
            'ne_states' => CachedMapItem.precomputed_data_origin_ids_for('ne_states')
          }

          ga_missing_gi_ids.each_slice(1000).with_index(1) do |ids, ga_batch|
            Parallel.each(ids, progress: "build_cached_map_item_translations GA (batch #{ga_batch})",
              in_processes: cached_rebuild_processes ) do |id|
              reconnected ||= CachedMapItemTranslation.connection.reconnect! || true
              process_asserted_distribution_translation(id, true, precomputed_data_origin_ids:)
            end
          end

          puts 'Geographic Area-based Asserted Distributions done.'

          gz_missing_gi_ids.each_slice(1000).with_index(1) do |ids, gz_batch|
            Parallel.each(ids, progress: "build_cached_map_item_translations GZ (batch #{gz_batch})",
              in_processes: cached_rebuild_processes ) do |id|
              reconnected ||= CachedMapItemTranslation.connection.reconnect! || true
              process_asserted_distribution_translation(id, false, precomputed_data_origin_ids:)
            end
          end

          puts 'Gazetteer-based Asserted Distributions done.'

          puts "Done. elapsed=#{(Time.current - task_start).round(2)}s"
        end

        def process_asserted_distribution_translation(
          geographic_item_id, geographic_area_based, precomputed_data_origin_ids: nil
        )
          translations = []

          #  b = ( Benchmark.measure {
          begin
            #  print "#{id}: "
            t = CachedMapItem.translate_geographic_item_id(
              geographic_item_id, geographic_area_based, false, ['ne_states'], nil, precomputed_data_origin_ids:
            )
            # if t.present?
            #   print t.join(', ')
            # else
            #   print ' !! NO MATCH'
            # end
          rescue ActiveRecord::StatementInvalid, ActiveRecord::RecordNotFound => e
            puts "#{geographic_item_id}:" + e.to_s.gsub(/\n/, '')
            t = []
          end

          #  })
          #  puts ' | ' + b.to_s

          t.each do |u|
            translations.push({
              geographic_item_id:,
              translated_geographic_item_id: u,
              cached_map_type: 'CachedMapItem::WebLevel1',
              created_at: Time.current,
              updated_at: Time.current,
            })
          end

          CachedMapItemTranslation.insert_all(translations) if translations.present?
        end

        # This is Idempotent
        desc 'index Georeferences with a "breadth-first" approach, idempotent '
        task parallel_create_cached_map_from_georeferences_by_area: [:environment] do |t|

          cached_rebuild_processes = ENV['cached_rebuild_processes'] ? ENV['cached_rebuild_processes'].to_i : 4

          g = GeographicArea.where(data_origin: ['ne_states']).select(:id, :parent_id)
          puts "Looping through #{g.size} GeographicAreas."

          Parallel.each(g.find_each, progress: 'build_cached_map_from_georeferences', in_processes: cached_rebuild_processes ) do |a|

            begin
              CachedMapItem.transaction do
                reconnected ||= CachedMapItemTranslation.connection.reconnect! || true

                j = a.default_geographic_item_id

                b = GeographicItem
                  .joins(:georeferences)
                  .where( GeographicItem.within_radius_of_item_sql(j, 0.0) )
                  .pluck(:id)

                r = Georeference
                  .joins(:geographic_item)
                  .where(geographic_item: {id: b })
                  .where.missing(:cached_map_register)
                  .distinct
                  .pluck(:id, :project_id)

                if r.any? # Do not repeat for already done Georeferences
                  o = Otu
                    .joins(:georeferences)
                    .where(georeferences: {id: r.map(&:first)})
                    .distinct
                    .pluck(:id, :project_id)

                  CachedMapItem.batch_create_georeference_cached_map_items(
                    { map_type: 'CachedMapItem::WebLevel1',
                      otu_id: o,
                      georeference_id: r,
                      geographic_item_id: b
                    }
                  )

                  puts "#{a.id} #{j}: #{b.size} #{r.size} #{o.size} "

                  true
                end
              end

            rescue => exception
              puts " FAILED #{exception} #{g.id}"
            end
          end
          puts 'Done.'
        end


      end
    end
  end
end

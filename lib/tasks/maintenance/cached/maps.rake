namespace :tw do
  namespace :maintenance do
    namespace :cached do

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

        def format_elapsed(start_time)
          s = (Time.current - start_time).to_i
          format('%d:%02d:%02d', s / 3600, (s % 3600) / 60, s % 60)
        end

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
          task_start = Time.current

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
          puts "Done labelling cached map items. elapsed=#{format_elapsed(task_start)}"
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
          task_start = Time.current
          # TODO: this doesn't currently account for FOs
          q = Georeference.joins(:otus).where.missing(:cached_map_register).distinct

          puts "Caching #{q.count} georeferences records."

          cached_rebuild_processes = ENV['cached_rebuild_processes'] ? ENV['cached_rebuild_processes'].to_i : 4

          # Pluck IDs only - avoids Parallel.each calling .to_a on the
          # enumerator and materializing all AR objects in the parent process.
          ids = q.pluck(:id)
          puts "Caching #{ids.size} georeferences records."

          slices = ids.each_slice(cached_rebuild_batch_size).to_a

          Parallel.each(slices, progress: 'build_cached_map_from_georeferences',
            in_processes: cached_rebuild_processes ) do |slice_ids|
            slice_start = Time.current
            registrations = []
            loaded_georefs = []
            context_miss = 0
            create_errors = 0
            build_context_ms = 0.0
            load_georef_ms = 0.0
            create_cmi_ms = 0.0
            register_insert_ms = 0.0
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
              build_context_ms = ((Time.current - slice_start) * 1000).round(1)

              # Group by collecting_event_id since georeference belongs_to
              # collecting_event - hash lookup replaces per-record queries.
              # Only include OTUs that have a taxon_name_id — OTUs without
              # taxon names have no hierarchy and don't contribute to cached maps.
              ce_otu_lookup = {}
              otu_rows.each do |ce_id, otu_id, taxon_name_id|
                next unless taxon_name_id
                (ce_otu_lookup[ce_id] ||= []) << otu_id
              end

              load_georef_start = Time.current
              loaded_georefs = Georeference.where(id: slice_ids).to_a
              load_georef_ms = ((Time.current - load_georef_start) * 1000).round(1)

              create_cmi_start = Time.current
              loaded_georefs.each do |g|
                otu_ids = ce_otu_lookup[g.collecting_event_id]
                unless otu_ids
                  context_miss += 1
                  next
                end
                begin
                  g.send(:create_cached_map_items, true,
                    context: { otu_id: otu_ids },
                    skip_register: true, register_queue: registrations)
                rescue ActiveRecord::StatementInvalid, ActiveRecord::RecordNotFound => e
                  create_errors += 1
                  puts " FAILED georeference_id:#{g.id} geographic_item_id:#{g.geographic_item_id} project_id:#{g.project_id} #{e}"
                end
              end
              create_cmi_ms = ((Time.current - create_cmi_start) * 1000).round(1)
              register_insert_start = Time.current
              CachedMapRegister.insert_all(registrations) if registrations.present?
              register_insert_ms = ((Time.current - register_insert_start) * 1000).round(1)
              true
            rescue => exception
              puts " FAILED #{exception} #{g.id}"
            end
            puts " slice ids:#{slice_ids.first}..#{slice_ids.last} n:#{slice_ids.size} loaded:#{loaded_georefs.size} context_miss:#{context_miss} errors:#{create_errors} regs:#{registrations.size} build_context_ms:#{build_context_ms} load_georef_ms:#{load_georef_ms} create_cmi_ms:#{create_cmi_ms} register_insert_ms:#{register_insert_ms} elapsed:#{(Time.current - slice_start).round(1)}s"
            true
          end

          puts "Done. elapsed=#{format_elapsed(task_start)}"
        end

        desc 'build CachedMapItems for AssertedDistributions that do not have them'
        task parallel_create_cached_map_from_asserted_distributions: [:environment] do |t|
          task_start = Time.current
          default_gagi_sql = GeographicAreasGeographicItem.default_geographic_item_data_sql
          ga_default_gi = ActiveRecord::Base.connection.select_rows(
            "SELECT default_gagi.geographic_area_id, default_gagi.geographic_item_id FROM (#{default_gagi_sql}) default_gagi"
          ).to_h { |ga_id, gi_id| [ga_id.to_i, gi_id.to_i] }

          q_ga = AssertedDistribution
            .with_otus
            .without_is_absent
            .where(asserted_distribution_shape_type: 'GeographicArea')
            .where.missing(:cached_map_register)
            .joins("JOIN geographic_areas ga ON asserted_distributions.asserted_distribution_shape_id = ga.id")

          q_gz = AssertedDistribution
            .with_otus
            .without_is_absent
            .where(asserted_distribution_shape_type: 'Gazetteer')
            .where.missing(:cached_map_register)
            .joins("JOIN gazetteers ON asserted_distributions.asserted_distribution_shape_id = gazetteers.id")

          ga_count = q_ga.unscope(:select).count
          gz_count = q_gz.unscope(:select).count
          puts "Caching #{ga_count + gz_count} AssertedDistribution records."

          # Pluck all needed context data from the expensive joined query ONCE.
          # The q_ga query includes a CTE (default_geographic_item_data_sql) with
          # a window function over the entire geographic_areas_geographic_items
          # table. Re-executing that per slice caused a 5x regression.
          ga_rows = q_ga.pluck(
            'asserted_distributions.id',
            'otus.id',
            'otus.taxon_name_id',
            'asserted_distributions.asserted_distribution_shape_id',
            'asserted_distributions.project_id'
          )
          ga_rows.map! do |ad_id, otu_id, otu_taxon_name_id, geographic_area_id, project_id|
            [ad_id, otu_id, otu_taxon_name_id, ga_default_gi[geographic_area_id.to_i], project_id]
          end

          gz_rows = q_gz.pluck(
            'asserted_distributions.id',
            'otus.id',
            'otus.taxon_name_id',
            'gazetteers.geographic_item_id',
            'asserted_distributions.project_id'
          )

          puts "Caching #{ga_rows.size} GA + #{gz_rows.size} GZ = #{ga_rows.size + gz_rows.size} AssertedDistribution records."

          [
            [ga_rows, true, 'build_cached_map_from_asserted_distributions GA'],
            [gz_rows, false, 'build_cached_map_from_asserted_distributions GZ']
          ].each do |rows, geographic_area_based, progress|
            # Build a lookup hash: ad_id => context
            ad_context = {}
            rows.each do |ad_id, otu_id, otu_taxon_name_id, geographic_item_id, project_id|
              ad_context[ad_id] = {
                otu_id:,
                otu_taxon_name_id:,
                geographic_item_id:,
                geographic_area_based:,
                require_existing_translation: true
              }
            end

            ad_ids = rows.map(&:first)
            slices = ad_ids.each_slice(cached_rebuild_batch_size).to_a

            Parallel.each(slices, progress:,
              in_processes: cached_rebuild_processes ) do |slice_ids|
              slice_start = Time.current
              registrations = []
              loaded_ads = []
              context_miss = 0
              create_errors = 0
              load_ad_ms = 0.0
              create_cmi_ms = 0.0
              register_insert_ms = 0.0
              begin
                reconnected ||= AssertedDistribution.connection.reconnect! || true # https://github.com/grosser/parallel

                # Simple primary-key lookup — no expensive CTE re-execution.
                load_ad_start = Time.current
                loaded_ads = AssertedDistribution.where(id: slice_ids).to_a
                load_ad_ms = ((Time.current - load_ad_start) * 1000).round(1)

                create_cmi_start = Time.current
                loaded_ads.each do |ad|
                  context = ad_context[ad.id]
                  unless context
                    context_miss += 1
                    next
                  end
                  begin
                    ad.send(:create_cached_map_items, true, context: context,
                      skip_register: true, register_queue: registrations)
                  rescue ActiveRecord::StatementInvalid, ActiveRecord::RecordNotFound => e
                    create_errors += 1
                    puts " FAILED asserted_distribution_id:#{ad.id} geographic_item_id:#{context[:geographic_item_id]} project_id:#{ad.project_id} #{e}"
                  end
                end
                create_cmi_ms = ((Time.current - create_cmi_start) * 1000).round(1)

                register_insert_start = Time.current
                CachedMapRegister.insert_all(registrations) if registrations.present?
                register_insert_ms = ((Time.current - register_insert_start) * 1000).round(1)
                true
              rescue => exception
                puts " FAILED #{exception} #{ad.id}"
              end
              puts " slice ids:#{slice_ids.first}..#{slice_ids.last} n:#{slice_ids.size} loaded:#{loaded_ads.size} context_miss:#{context_miss} errors:#{create_errors} regs:#{registrations.size} load_ad_ms:#{load_ad_ms} create_cmi_ms:#{create_cmi_ms} register_insert_ms:#{register_insert_ms} elapsed:#{(Time.current - slice_start).round(1)}s"
              true
            end
          end

          puts "Done. elapsed=#{format_elapsed(task_start)}"
        end

        desc 'prebuild CachedMapItemTranslations, NOT idempotent'
        task parallel_create_cached_map_item_translations_from_asserted_distributions: [:environment] do |t|
          cached_rebuild_processes = ENV['cached_rebuild_processes'] ? ENV['cached_rebuild_processes'].to_i : 4

          # ids = GeographicAreasGeographicItem.where(geographic_area: GeographicArea.joins(:asserted_distributions))
          #        .where.missing(:cached_map_item_translations)
          #        .default_geographic_item_data   # This does not do what we want it do as a join
          #        .select(:geographic_item_id)
          #        .distinct
          #        .pluck(:geographic_item_id)

          puts 'Preparing...'

          ids_out = CachedMapItemTranslation.select(:geographic_item_id)
          .distinct.pluck(:geographic_item_id).compact

          ids_in__ga = GeographicArea.joins(:asserted_distributions).distinct
            .map(&:default_geographic_item_id).compact
          puts "Total GeographicArea-based asserted distributions: #{ids_in__ga.count}"
          puts "GeographicArea-based asserted distributions already done: #{(ids_out & ids_in__ga).count}"

          ids_in__gz = Gazetteer.joins(:asserted_distributions).distinct
            .map(&:default_geographic_item_id).compact
          puts "Total Gazetteer-based asserted distributions: #{ids_in__gz.count}"
          puts "Gazetteer-based asserted distributions already done: #{(ids_out & ids_in__gz).count}"

          ids_in__ga = ids_in__ga - ids_out
          ids_in__gz = ids_in__gz - ids_out

          puts "Processing #{ids_in__ga.count} GeographicArea-based asserted distributions"
          puts "Processing #{ids_in__gz.count} Gazetteer-based asserted distributions"

          precomputed_data_origin_ids = {
            'ne_states' => CachedMapItem.precomputed_data_origin_ids_for('ne_states')
          }

          ids_in__ga.sort!
          ids_in__gz.sort!

          Parallel.each(ids_in__ga, progress: 'build_cached_map_item_translations GA', in_processes: cached_rebuild_processes ) do |id|
            reconnected ||= CachedMapItemTranslation.connection.reconnect! || true
            process_asserted_distribution_translation(id, true, precomputed_data_origin_ids:)
          end

          puts 'Geographic Area-based Asserted Distributions done.'

          Parallel.each(ids_in__gz, progress: 'build_cached_map_item_translations GZ', in_processes: cached_rebuild_processes ) do |id|
            reconnected ||= CachedMapItemTranslation.connection.reconnect! || true
            process_asserted_distribution_translation(id, false, precomputed_data_origin_ids:)
          end

          puts 'Gazetteer-based Asserted Distributions done.'

          puts "Done. elapsed=#{format_elapsed(task_start)}"
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
          rescue ActiveRecord::StatementInvalid, ActiveRecord::RecordNotFound => e
            context = translation_failure_context(geographic_item_id, geographic_area_based)
            puts " FAILED translation geographic_item_id:#{geographic_item_id} geographic_area_based:#{geographic_area_based} total_matching_ads:#{context[:total_matching_ads]} sample_asserted_distribution_ids:#{context[:sample_ad_ids].join(',')} sample_project_ids:#{context[:sample_project_ids].join(',')} #{e.to_s.gsub(/\n/, '')}"
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

        def translation_failure_context(geographic_item_id, geographic_area_based, sample_limit: 5)
          q = AssertedDistribution
            .without_is_absent
            .where(asserted_distribution_shape_type: geographic_area_based ? 'GeographicArea' : 'Gazetteer')

          if geographic_area_based
            default_gagi_sql = GeographicAreasGeographicItem.default_geographic_item_data_sql
            q = q
              .joins("JOIN geographic_areas ga ON asserted_distributions.asserted_distribution_shape_id = ga.id")
              .joins("JOIN (#{default_gagi_sql}) default_gagi ON default_gagi.geographic_area_id = ga.id")
              .where('default_gagi.geographic_item_id = ?', geographic_item_id)
          else
            q = q
              .joins("JOIN gazetteers ON asserted_distributions.asserted_distribution_shape_id = gazetteers.id")
              .where('gazetteers.geographic_item_id = ?', geographic_item_id)
          end

          total_matching_ads = q.count

          sample = q
            .limit(sample_limit)
            .pluck('asserted_distributions.id', 'asserted_distributions.project_id')

          {
            total_matching_ads:,
            sample_ad_ids: sample.map(&:first).compact.uniq,
            sample_project_ids: sample.map(&:last).compact.uniq
          }
        end

        # This is Idempotent
        desc 'index Georeferences with a "breadth-first" approach, idempotent '
        task parallel_create_cached_map_from_georeferences_by_area: [:environment] do |t|
          task_start = Time.current

          cached_rebuild_processes = ENV['cached_rebuild_processes'] ? ENV['cached_rebuild_processes'].to_i : 4

          g = GeographicArea.where(data_origin: ['ne_states']).select(:id, :parent_id)
          puts "Looping through #{g.size} GeographicAreas."

          Parallel.each(g.find_each, progress: 'build_cached_map_from_georeferences', in_processes: cached_rebuild_processes ) do |a|
            reconnected ||= CachedMapItemTranslation.connection.reconnect! || true

            begin
              CachedMapItem.transaction do

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
          puts "Done. elapsed=#{format_elapsed(task_start)}"
        end


      end
    end
  end
end

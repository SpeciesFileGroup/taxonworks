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

        def sql_upsert_cached_map_items_from_counts_sql(counts_sql)
          <<~SQL
            WITH counts AS (
              #{counts_sql}
            )
            INSERT INTO cached_map_items (
              type,
              otu_id,
              geographic_item_id,
              project_id,
              reference_count,
              untranslated,
              created_at,
              updated_at
            )
            SELECT
              counts.type,
              counts.otu_id,
              counts.geographic_item_id,
              counts.project_id,
              counts.reference_count,
              FALSE,
              NOW(),
              NOW()
            FROM counts
            ON CONFLICT (type, otu_id, geographic_item_id, project_id)
            DO UPDATE SET
              reference_count = COALESCE(cached_map_items.reference_count, 0) + EXCLUDED.reference_count,
              updated_at = NOW();
          SQL
        end

        def sql_insert_cached_map_registers_from_source_sql(source_sql, object_type: 'AssertedDistribution', id_column: 'ad_id')
          <<~SQL
            WITH source_rows AS (
              #{source_sql}
            )
            INSERT INTO cached_map_registers (
              cached_map_register_object_type,
              cached_map_register_object_id,
              project_id,
              created_at,
              updated_at
            )
            SELECT
              '#{object_type}',
              source_rows.#{id_column},
              source_rows.project_id,
              NOW(),
              NOW()
            FROM source_rows
            ON CONFLICT (cached_map_register_object_type, cached_map_register_object_id)
            DO NOTHING;
          SQL
        end

        def sql_upsert_cached_map_items_with_untranslated_from_counts_sql(counts_sql)
          <<~SQL
            WITH counts AS (
              #{counts_sql}
            )
            INSERT INTO cached_map_items (
              type,
              otu_id,
              geographic_item_id,
              project_id,
              reference_count,
              untranslated,
              created_at,
              updated_at
            )
            SELECT
              counts.type,
              counts.otu_id,
              counts.geographic_item_id,
              counts.project_id,
              counts.reference_count,
              counts.untranslated,
              NOW(),
              NOW()
            FROM counts
            ON CONFLICT (type, otu_id, geographic_item_id, project_id)
            DO UPDATE SET
              reference_count = COALESCE(cached_map_items.reference_count, 0) + EXCLUDED.reference_count,
              untranslated = COALESCE(cached_map_items.untranslated, FALSE) OR COALESCE(EXCLUDED.untranslated, FALSE),
              updated_at = NOW();
          SQL
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

          unless ActiveRecord::Base.connection.index_exists?(
            :cached_map_items,
            [:type, :otu_id, :geographic_item_id, :project_id],
            unique: true,
            name: :index_cached_map_items_on_type_otu_gi_project
          )
            raise 'SQL aggregate georef cache build requires unique index index_cached_map_items_on_type_otu_gi_project. Run migrations first.'
          end

          puts "Using SQL aggregate georef cache build path."

          connection = ActiveRecord::Base.connection
          cmi_before = CachedMapItem.count
          cmr_before = CachedMapRegister.where(cached_map_register_object_type: 'Georeference').count

          precomputed_state_ids = CachedMapItem.precomputed_data_origin_ids_for('ne_states')

          georef_base_sql = <<~SQL.squish
            SELECT DISTINCT
              g.id AS georef_id,
              g.project_id AS project_id,
              td_paths.otu_id AS otu_id,
              g.geographic_item_id AS source_geographic_item_id
            FROM georeferences g
            LEFT JOIN cached_map_registers cmr
              ON cmr.cached_map_register_object_type = 'Georeference'
              AND cmr.cached_map_register_object_id = g.id
            JOIN (
              SELECT
                co.collecting_event_id AS collecting_event_id,
                td.otu_id AS otu_id
              FROM collection_objects co
              JOIN taxon_determinations td
                ON td.taxon_determination_object_type = 'CollectionObject'
                AND td.taxon_determination_object_id = co.id
                AND td.position = 1
              UNION ALL
              SELECT
                fo.collecting_event_id AS collecting_event_id,
                td.otu_id AS otu_id
              FROM field_occurrences fo
              JOIN taxon_determinations td
                ON td.taxon_determination_object_type = 'FieldOccurrence'
                AND td.taxon_determination_object_id = fo.id
                AND td.position = 1
            ) td_paths
              ON td_paths.collecting_event_id = g.collecting_event_id
            JOIN otus
              ON otus.id = td_paths.otu_id
            WHERE
              g.position = 1
              AND cmr.id IS NULL
              AND otus.taxon_name_id IS NOT NULL
          SQL

          georef_total = connection.select_value("SELECT COUNT(*) FROM (#{georef_base_sql}) base").to_i
          puts "Caching #{georef_total} georeference-OTU rows (SQL aggregate)."

          georef_counts_sql = <<~SQL.squish
            WITH base AS (
              #{georef_base_sql}
            ),
            source_geographic_items AS (
              SELECT DISTINCT base.source_geographic_item_id
              FROM base
            ),
            translated_by_source AS (
              SELECT
                sgi.source_geographic_item_id,
                translated_gi.id AS translated_geographic_item_id
              FROM source_geographic_items sgi
              JOIN geographic_items source_gi
                ON source_gi.id = sgi.source_geographic_item_id
              LEFT JOIN geographic_items translated_gi
                ON translated_gi.id IN (#{precomputed_state_ids})
                AND ST_Intersects(translated_gi.geography, source_gi.geography)
            )
            SELECT
              'CachedMapItem::WebLevel1'::text AS type,
              base.otu_id,
              COALESCE(tbs.translated_geographic_item_id, base.source_geographic_item_id) AS geographic_item_id,
              base.project_id,
              COUNT(*)::integer AS reference_count,
              (tbs.translated_geographic_item_id IS NULL) AS untranslated
            FROM base
            LEFT JOIN translated_by_source tbs
              ON tbs.source_geographic_item_id = base.source_geographic_item_id
            GROUP BY
              base.otu_id,
              COALESCE(tbs.translated_geographic_item_id, base.source_geographic_item_id),
              base.project_id,
              (tbs.translated_geographic_item_id IS NULL)
          SQL
          cmi_start = Time.current
          connection.execute(sql_upsert_cached_map_items_with_untranslated_from_counts_sql(georef_counts_sql))
          puts "build_cached_map_from_georeferences (sql_aggregate) |Time: #{format_elapsed(cmi_start)}"

          georef_register_sql = <<~SQL.squish
            SELECT DISTINCT
              g.id AS georef_id,
              g.project_id AS project_id
            FROM georeferences g
            LEFT JOIN cached_map_registers cmr
              ON cmr.cached_map_register_object_type = 'Georeference'
              AND cmr.cached_map_register_object_id = g.id
            WHERE
              g.position = 1
              AND cmr.id IS NULL
              AND (
                EXISTS (
                  SELECT 1
                  FROM collection_objects co
                  JOIN taxon_determinations td
                    ON td.taxon_determination_object_type = 'CollectionObject'
                    AND td.taxon_determination_object_id = co.id
                  JOIN otus ON otus.id = td.otu_id
                  WHERE co.collecting_event_id = g.collecting_event_id
                    AND td.position = 1
                    AND otus.taxon_name_id IS NOT NULL
                )
                OR EXISTS (
                  SELECT 1
                  FROM field_occurrences fo
                  JOIN taxon_determinations td
                    ON td.taxon_determination_object_type = 'FieldOccurrence'
                    AND td.taxon_determination_object_id = fo.id
                  JOIN otus ON otus.id = td.otu_id
                  WHERE fo.collecting_event_id = g.collecting_event_id
                    AND td.position = 1
                    AND otus.taxon_name_id IS NOT NULL
                )
              )
          SQL
          register_start = Time.current
          connection.execute(
            sql_insert_cached_map_registers_from_source_sql(
              georef_register_sql,
              object_type: 'Georeference',
              id_column: 'georef_id'
            )
          )
          puts "register_cached_map_from_georeferences (sql_aggregate) |Time: #{format_elapsed(register_start)}"

          cmi_after = CachedMapItem.count
          cmr_after = CachedMapRegister.where(cached_map_register_object_type: 'Georeference').count
          puts "SQL aggregate georef cache delta: cached_map_items +#{cmi_after - cmi_before}, georeference_registers +#{cmr_after - cmr_before}"

          puts "Done. elapsed=#{format_elapsed(task_start)}"
        end

        desc 'build CachedMapItems for AssertedDistributions that do not have them, idempotent'
        task parallel_create_cached_map_from_asserted_distributions: [:environment] do |t|
          task_start = Time.current
          default_gagi_sql = GeographicAreasGeographicItem.default_geographic_item_data_sql

          clean_slate =
            CachedMapItem.count.zero? &&
            CachedMapRegister.count.zero?

          unless ActiveRecord::Base.connection.index_exists?(
            :cached_map_items,
            [:type, :otu_id, :geographic_item_id, :project_id],
            unique: true,
            name: :index_cached_map_items_on_type_otu_gi_project
          )
            raise 'SQL aggregate AD cache build requires unique index index_cached_map_items_on_type_otu_gi_project. Run migrations first.'
          end

          puts "Using SQL aggregate AD cache build path (clean_slate=#{clean_slate})."

          connection = ActiveRecord::Base.connection
          cmi_before = CachedMapItem.count
          cmr_before = CachedMapRegister.where(cached_map_register_object_type: 'AssertedDistribution').count

            ga_base_sql = <<~SQL.squish
              SELECT
                ad.id AS ad_id,
                ad.project_id AS project_id,
                otus.id AS otu_id,
                default_gagi.geographic_item_id AS source_geographic_item_id
              FROM asserted_distributions ad
              JOIN otus
                ON ad.asserted_distribution_object_type = 'Otu'
                AND ad.asserted_distribution_object_id = otus.id
              LEFT JOIN cached_map_registers cmr
                ON cmr.cached_map_register_object_type = 'AssertedDistribution'
                AND cmr.cached_map_register_object_id = ad.id
              JOIN geographic_areas ga
                ON ad.asserted_distribution_shape_id = ga.id
              JOIN (#{default_gagi_sql}) default_gagi
                ON default_gagi.geographic_area_id = ga.id
              WHERE
                ad.asserted_distribution_shape_type = 'GeographicArea'
                AND COALESCE(ad.is_absent, FALSE) = FALSE
                AND cmr.id IS NULL
                AND otus.taxon_name_id IS NOT NULL
            SQL

            gz_base_sql = <<~SQL.squish
              SELECT
                ad.id AS ad_id,
                ad.project_id AS project_id,
                otus.id AS otu_id,
                gazetteers.geographic_item_id AS source_geographic_item_id
              FROM asserted_distributions ad
              JOIN otus
                ON ad.asserted_distribution_object_type = 'Otu'
                AND ad.asserted_distribution_object_id = otus.id
              LEFT JOIN cached_map_registers cmr
                ON cmr.cached_map_register_object_type = 'AssertedDistribution'
                AND cmr.cached_map_register_object_id = ad.id
              JOIN gazetteers
                ON ad.asserted_distribution_shape_id = gazetteers.id
              WHERE
                ad.asserted_distribution_shape_type = 'Gazetteer'
                AND COALESCE(ad.is_absent, FALSE) = FALSE
                AND cmr.id IS NULL
                AND otus.taxon_name_id IS NOT NULL
            SQL

          ga_total_sql = <<~SQL.squish
            SELECT COUNT(*)
            FROM asserted_distributions ad
            JOIN otus
              ON ad.asserted_distribution_object_type = 'Otu'
              AND ad.asserted_distribution_object_id = otus.id
            LEFT JOIN cached_map_registers cmr
              ON cmr.cached_map_register_object_type = 'AssertedDistribution'
              AND cmr.cached_map_register_object_id = ad.id
            WHERE
              ad.asserted_distribution_shape_type = 'GeographicArea'
              AND COALESCE(ad.is_absent, FALSE) = FALSE
              AND cmr.id IS NULL
              AND otus.taxon_name_id IS NOT NULL
          SQL

          ga_total = connection.select_value(ga_total_sql).to_i
          ga_with_default = connection.select_value("SELECT COUNT(*) FROM (#{ga_base_sql}) ga").to_i
          ga_missing_default_gi = ga_total - ga_with_default
          puts "Skipping #{ga_missing_default_gi} GA AssertedDistribution rows without default geographic_item_id." if ga_missing_default_gi.positive?

          gz_rows_count = connection.select_value("SELECT COUNT(*) FROM (#{gz_base_sql}) gz").to_i
          puts "Caching #{ga_with_default} GA + #{gz_rows_count} GZ = #{ga_with_default + gz_rows_count} AssertedDistribution records."

          ga_counts_sql = <<~SQL.squish
            SELECT
              'CachedMapItem::WebLevel1'::text AS type,
              ga.otu_id,
              t.translated_geographic_item_id AS geographic_item_id,
              ga.project_id,
              COUNT(*)::integer AS reference_count
            FROM (#{ga_base_sql}) ga
            JOIN cached_map_item_translations t
              ON t.cached_map_type = 'CachedMapItem::WebLevel1'
              AND t.geographic_item_id = ga.source_geographic_item_id
            GROUP BY ga.otu_id, t.translated_geographic_item_id, ga.project_id
          SQL

          gz_counts_sql = <<~SQL.squish
            SELECT
              'CachedMapItem::WebLevel1'::text AS type,
              gz.otu_id,
              t.translated_geographic_item_id AS geographic_item_id,
              gz.project_id,
              COUNT(*)::integer AS reference_count
            FROM (#{gz_base_sql}) gz
            JOIN cached_map_item_translations t
              ON t.cached_map_type = 'CachedMapItem::WebLevel1'
              AND t.geographic_item_id = gz.source_geographic_item_id
            GROUP BY gz.otu_id, t.translated_geographic_item_id, gz.project_id
          SQL

          ga_cmi_start = Time.current
          connection.execute(sql_upsert_cached_map_items_from_counts_sql(ga_counts_sql))
          puts "build_cached_map_from_asserted_distributions GA (sql_aggregate) |Time: #{format_elapsed(ga_cmi_start)}"

          gz_cmi_start = Time.current
          connection.execute(sql_upsert_cached_map_items_from_counts_sql(gz_counts_sql))
          puts "build_cached_map_from_asserted_distributions GZ (sql_aggregate) |Time: #{format_elapsed(gz_cmi_start)}"

          ga_reg_start = Time.current
          connection.execute(sql_insert_cached_map_registers_from_source_sql(ga_base_sql))
          puts "register_cached_map_from_asserted_distributions GA (sql_aggregate) |Time: #{format_elapsed(ga_reg_start)}"

          gz_reg_start = Time.current
          connection.execute(sql_insert_cached_map_registers_from_source_sql(gz_base_sql))
          puts "register_cached_map_from_asserted_distributions GZ (sql_aggregate) |Time: #{format_elapsed(gz_reg_start)}"

          cmi_after = CachedMapItem.count
          cmr_after = CachedMapRegister.where(cached_map_register_object_type: 'AssertedDistribution').count
          puts "SQL aggregate AD cache delta: cached_map_items +#{cmi_after - cmi_before}, asserted_distribution_registers +#{cmr_after - cmr_before}"

          puts "Done. elapsed=#{format_elapsed(task_start)}"
        end

        desc 'prebuild CachedMapItemTranslations, idempotent'
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

          ga_gi_ids = GeographicArea.joins(:asserted_distributions)
            .merge(AssertedDistribution.without_is_absent)
            .joins("JOIN (#{default_gagi_sql}) default_gagi ON default_gagi.geographic_area_id = geographic_areas.id")
            .select('DISTINCT default_gagi.geographic_item_id AS id')

          gz_gi_ids = Gazetteer.joins(:asserted_distributions)
            .merge(AssertedDistribution.without_is_absent)
            .select('DISTINCT gazetteers.geographic_item_id AS id')

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
          slow_translation_ms = ENV.fetch('cached_translation_slow_ms', '600000').to_f
          translation_elapsed_ms = 0.0

          #  b = ( Benchmark.measure {
          begin
            translation_start = Time.current
            t = CachedMapItem.translate_geographic_item_id(
              geographic_item_id, geographic_area_based, false, ['ne_states'], nil, precomputed_data_origin_ids:
            )
            translation_elapsed_ms = ((Time.current - translation_start) * 1000).round(1)
            if translation_elapsed_ms >= slow_translation_ms
              context = translation_failure_context(geographic_item_id, geographic_area_based)
              puts " SLOW translation geographic_item_id:#{geographic_item_id} geographic_area_based:#{geographic_area_based} elapsed_ms:#{translation_elapsed_ms} threshold_ms:#{slow_translation_ms} total_matching_ads:#{context[:total_matching_ads]} sample_asserted_distribution_ids:#{context[:sample_ad_ids].join(',')} sample_project_ids:#{context[:sample_project_ids].join(',')}"
            end
          rescue ActiveRecord::StatementInvalid, ActiveRecord::RecordNotFound => e
            context = translation_failure_context(geographic_item_id, geographic_area_based)
            puts " FAILED translation geographic_item_id:#{geographic_item_id} geographic_area_based:#{geographic_area_based} elapsed_ms:#{translation_elapsed_ms} total_matching_ads:#{context[:total_matching_ads]} sample_asserted_distribution_ids:#{context[:sample_ad_ids].join(',')} sample_project_ids:#{context[:sample_project_ids].join(',')} #{e.to_s.gsub(/\n/, '')}"
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

          CachedMapItemTranslation.insert_all(
            translations,
            unique_by: :cmgit_translation
          ) if translations.present?
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

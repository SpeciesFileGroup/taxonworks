namespace :tw do
  namespace :maintenance do
    namespace :cached do

      # !! These tasks only build new records. They will not syncronize/refresh existing records. !!
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

        desc 'destroy all cached map references'
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
              .where.not(untranslated: true)

            puts 'Size: ' + z.size.to_s

            z.update_all(
              level0_geographic_name: h[:country],
              level1_geographic_name: h[:state],
              level2_geographic_name: h[:county]
            )

            puts o.geographic_item_id
            puts h
          end
          puts 'Done labelling cached map items.'
        end

        # NOT considered a batch = true method (labels as it builds)
        desc 'build CachedMapItems for an OTU, idempotent'
        task parallel_create_cached_map_for_otu: [:environment] do |t|

          cached_rebuild_processes = ENV['cached_rebuild_processes'] ? ENV['cached_rebuild_processes'].to_i : 4

          otu = Otu.find(ENV['otu_id'])

          puts "Building for #{otu.name}: #{otu.taxon_name.cached} ..."

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
          q = Georeference.joins(:otus).where.missing(:cached_map_register).distinct

          puts "Caching #{q.all.size} georeferences records."

          cached_rebuild_processes = ENV['cached_rebuild_processes'] ? ENV['cached_rebuild_processes'].to_i : 4

          Parallel.each(q.find_each, progress: 'build_cached_map_from_georeferences', in_processes: cached_rebuild_processes ) do |g|
            begin
              CachedMapItem.transaction do
                reconnected ||= Georeference.connection.reconnect! || true # https://github.com/grosser/parallel
                g.send(:create_cached_map_items, true)
              end
              true
            rescue => exception
              puts " FAILED #{exception} #{g.id}"
            end
            true
          end

          puts 'Done.'
        end

        desc 'build CachedMapItems for AssertedDistributions that do not have them'
        task parallel_create_cached_map_from_asserted_distributions: [:environment] do |t|
          q = AssertedDistribution.joins(:geographic_items).where.missing(:cached_map_register).distinct

          puts "Caching #{q.all.size} AssertedDistribution records."

          cached_rebuild_processes = ENV['cached_rebuild_processes'] ? ENV['cached_rebuild_processes'].to_i : 4

          Parallel.each(q.find_each, progress: 'build_cached_map_from_asserted_distributions', in_processes: cached_rebuild_processes ) do |ad|
            begin
              CachedMapItem.transaction do
                reconnected ||= AssertedDistribution.connection.reconnect! || true # https://github.com/grosser/parallel
                ad.send(:create_cached_map_items, true)
              end
              true
            rescue => exception
              puts " FAILED #{exception} #{ad.id}"
            end
            true
          end

          puts'Done.'
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

          ids_in = GeographicArea.joins(:asserted_distributions).distinct.map(&:default_geographic_item_id).compact
          puts "Total: #{ids_in.count}"

          ids_out = CachedMapItemTranslation.select(:geographic_item_id).distinct.pluck(:geographic_item_id).compact
          puts "Already done: #{ids_out.count}"

          ids_in = ids_in - ids_out
          puts "Processing: #{ids_in.count}"

          ids_in.sort!

          Parallel.each(ids_in, progress: 'build_cached_map_item_translations', in_processes: cached_rebuild_processes ) do |id|
            reconnected ||= CachedMapItemTranslation.connection.reconnect! || true

            translations = []

            #  b = ( Benchmark.measure {
            begin
              #  print "#{id}: "
              t = CachedMapItem.translate_by_spatial_overlap(id, ['ne_states'], 90.0)
              # if t.present?
              #   print t.join(', ')
              # else
              #   print ' !! NO MATCH'
              # end
            rescue ActiveRecord::StatementInvalid  => e
              puts "#{id}:" + e.to_s.gsub(/\n/, '')
              t = []
            end

            #  })
            #  puts ' | ' + b.to_s

            t.each do |u|
              translations.push({
                geographic_item_id: id,
                translated_geographic_item_id: u,
                cached_map_type: 'CachedMapItem::WebLevel1',
                created_at: Time.current,
                updated_at: Time.current,
              })
            end

            CachedMapItemTranslation.insert_all(translations) if translations.present?
          end

          puts 'Done.'
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

                  puts "#{a.id} #{j}: #{b.size} #{r.size} #{o.size}"

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

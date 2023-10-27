namespace :tw do
  namespace :maintenance do
    namespace :cached do

      # !! These tasks only build new records.  They will not syncronize/refresh. !!
      #
      # The index can be built all at once with
      #
      #  rake tw:maintenance:cached:maps:full_index
      #
      # This fires three tasks that can be run individually, and idempotently, though the last ("label") should be run
      # at the completion of of the cache build.
      #
      # rake tw:maintenance:cached:maps:parallel_create_cached_map_from_asserted_distributions cached_rebuild_processes=4
      # rake tw:maintenance:cached:maps:parallel_create_cached_map_from_georeferences cached_rebuild_processes=4
      # rake tw:maintenance:cached:maps:parallel_label_cached_map_items cached_rebuild_processes=4
      #
      # You can target a build for a specific OTU with:
      #
      #  rake tw:maintenance:cached:maps:parallel_create_cached_map_for_otu otu_id=123 cached_rebuild_processes=4
      #
      # You can destroy *everything* related to CachedMap<X> with
      #
      # rake tw:maintenance:cached:maps:nuke_cached_maps
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
        task nuke_cached_maps: [:environment] do |t|
          puts 'Nuking cached maps'
          CachedMap.delete_all
          CachedMapRegister.delete_all
          CachedMapItemTranslation.delete_all
          CachedMapItem.delete_all
          puts 'Done.'
        end

        desc 'create and label a full index run'
        task full_index: [:parallel_create_cached_map_from_asserted_distributions, :parallel_create_cached_map_from_georeferences, :parallel_label_cached_map_items] do |t|
          puts 'Done full index.'
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
        desc 'build CachedMapItems for an OTU'
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

        desc 'build CachedMapItems for Georeferences that do not have them'
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
      end
    end
  end
end

namespace :tw do
  namespace :maintenance do
    namespace :cached do

      # !! These tasks only build new records.  They will not refresh and clean/remove stale data. !!
      #
      # The index is build in two tasks:
      #
      # rake tw:maintenance:cached:maps:parallel_create_cached_map_from_asserted_distributions cached_rebuild_processes=4
      # rake tw:maintenance:cached:maps:parallel_create_cached_map_from_georeferences cached_rebuild_processes=4
      #
      # They can be started or stopped at any point.
      #
      # You can target a build for a specific OTU with:
      #
      #  rake tw:maintenance:cached:maps:parallel_create_cached_map_for_otu otu_id=123 cached_rebuild_processes=4
      #
      namespace :maps do

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
              ce.georeferences.where.missing(:cached_map_register).each do |g|

                begin
                  CachedMapItem.transaction do
                    reconnected ||= Georeference.connection.reconnect! || true # https://github.com/grosser/parallel
                    g.send(:create_cached_map_items)
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
                  ad.send(:create_cached_map_items)
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
          q = Georeference.where.missing(:cached_map_register)

          puts "Caching #{q.all.size} georeferences records."

          cached_rebuild_processes = ENV['cached_rebuild_processes'] ? ENV['cached_rebuild_processes'].to_i : 4

          Parallel.each(q.find_each, progress: 'build_cached_map_from_georeferences', in_processes: cached_rebuild_processes ) do |g|
            begin
              CachedMapItem.transaction do
                reconnected ||= Georeference.connection.reconnect! || true # https://github.com/grosser/parallel
                g.send(:create_cached_map_items)
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
          q = AssertedDistribution.joins(:geographic_items).where.missing(:cached_map_register)

          puts "Caching #{q.all.size} AssertedDistribution records."

          cached_rebuild_processes = ENV['cached_rebuild_processes'] ? ENV['cached_rebuild_processes'].to_i : 4

          Parallel.each(q.find_each, progress: 'build_cached_map_from_asserted_distributions', in_processes: cached_rebuild_processes ) do |ad|
            begin
              CachedMapItem.transaction do
                reconnected ||= AssertedDistribution.connection.reconnect! || true # https://github.com/grosser/parallel
                ad.send(:create_cached_map_items)
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

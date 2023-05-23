namespace :tw do
  namespace :maintenance do
    namespace :cached do
  
      # The index is build in two tasks:
      #
      # rake tw:maintenance:cached:maps:parallel_create_cached_map_from_asserted_distributions cached_rebuild_processes=4 
      # rake tw:maintenance:cached:maps:parallel_create_cached_map_from_georeferences cached_rebuild_processes=4 
      #
      # They can be started or stopped at any point.
      namespace :maps do

 
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

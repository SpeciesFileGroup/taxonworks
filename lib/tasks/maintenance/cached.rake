namespace :tw do
  namespace :maintenance do
    namespace :cached do

      # This task does not touch Housekeeping!a
      desc 'rake tw:maintenance:cached:parallel_rebuild_cached_original_combinations project_id=1 cached_rebuild_processes=16'
      task parallel_rebuild_cached_original_combinations: [:environment, :project_id] do |t|
        GC.start # VERY important, line below will fork into [number of threads] copies of this process, so memory usage must be as minimal as possible before starting.
        # Runs in parallel only if PARALLEL_PROCESSOR_COUNT is explicitely set
        #
        query = Protonym.is_species_or_genus_group
          .joins(:original_combination_relationships)
          .where(
            project_id: Current.project_id,
            cached_original_combination: nil)

        puts Rainbow("Processing #{query.count} records").purple

        cached_rebuild_processes = ENV['cached_rebuild_processes'] ? ENV['cached_rebuild_processes'].to_i : 16

        Parallel.each(query.find_each, progress: 'update_cached_original_combinations', in_processes: cached_rebuild_processes ) do |n|
          begin
            n.update_cached_original_combinations
          rescue => exception
            puts Rainbow(" FAILED #{e}").red.bold
          end
        end
      end


      # This task does not touch Housekeeping!
      desc 'rake tw:maintenance:cached:rebuild_cached_original_combinations project_id=1'
      task  rebuild_cached_original_combinations: [:environment, :project_id] do |t|
        query = Protonym.is_species_or_genus_group
          .joins(:original_combination_relationships)
          .where(
            project_id: Current.project_id,
            cached_original_combination: nil)

        puts Rainbow("Processing #{query.count} records").purple

        query.find_each do |p|
          print Rainbow( p.name + ' [' + p.id.to_s + ']' ).yellow
          begin
            p.update_cached_original_combinations
            puts Rainbow(' PROCESSED OK').green.bold
          rescue => e
            puts Rainbow(" FAILED #{e}").red.bold
          end
        end
      end
    end

  end
end


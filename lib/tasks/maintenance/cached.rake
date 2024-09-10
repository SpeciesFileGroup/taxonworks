namespace :tw do
  namespace :maintenance do
    namespace :cached do

      # rake tw:maintenance:cached:parallel_rebuild_collecting_event_cached_adm_fields project_id=55 cached_rebuild_processes=4
      desc 'rebuild of CollectingEvent cached_adm* fields'
      task parallel_rebuild_collecting_event_cached_adm_fields: [:environment] do |t|

        cached_rebuild_processes = ENV['cached_rebuild_processes'] ? ENV['cached_rebuild_processes'].to_i : 16

        q = CollectingEvent.select(:id, :geographic_area_id, :meta_prioritize_geographic_area, :verbatim_latitude, :verbatim_longitude, :verbatim_elevation).all

        if ENV['project_id']
          q = q.where(project_id: ENV['project_id'])
        end

        Parallel.each(q.find_each, progress: 'update_collecting_event_cached_adm_fields', in_processes: cached_rebuild_processes ) do |c|
          c.send(:set_cached_geographic_names)
        end
      end

      desc 'forces rebuild of all GeographicItem cached fields'
      task parallel_reset_geographic_item_cached_ids: [:environment] do |t|

        cached_rebuild_processes = ENV['cached_rebuild_processes'] ? ENV['cached_rebuild_processes'].to_i : 16

        q = GeographicItem.all

        Parallel.each(q.find_each, progress: 'update_geographic_item_cached_fields', in_processes: cached_rebuild_processes ) do |gi|
            begin
              gi.set_cached
            rescue => exception
              puts Rainbow(" FAILED #{exception}").red.bold
            end
          end
      end


      # If force = 'true' then re-do records that already have cached set
      desc 'rake tw:maintenance:cached:parallel_rebuild_cached_author force=true cached_rebuild_processes=4'
      task parallel_rebuild_cached_author: [:environment] do |t|

        a = TaxonName.where.not(verbatim_author: nil)
        b = TaxonName.joins(:taxon_name_authors) # TODO: should be Protonym + what Plant/other names?

        query = TaxonName.from("((#{a.to_sql}) UNION (#{b.to_sql})) as taxon_names")

        if ENV['force'] != 'true'
          query = query.where(cached_author: nil)
        end

        puts Rainbow("Processing #{query.count} records").purple

        cached_rebuild_processes = ENV['cached_rebuild_processes'] ? ENV['cached_rebuild_processes'].to_i : 16

        #  !! Parallel *does not* like query.find_each !!
        Parallel.each(query.each, progress: 'update_cached_author', in_processes: cached_rebuild_processes ) do |n|
          begin
            n.set_cached_author
          rescue => exception
            puts Rainbow(" FAILED #{exception}").red.bold
          end
          true
        end
      end

      # This task does not touch Housekeeping!
      desc 'rake tw:maintenance:cached:parallel_rebuild_cached_original_combinations project_id=1 cached_rebuild_processes=16'
      task parallel_rebuild_cached_original_combinations: [:environment, :project_id] do |t|
        GC.start # VERY important, line below will fork into [number of threads] copies of this process, so memory usage must be as minimal as possible before starting.
        # Runs in parallel only if PARALLEL_PROCESSOR_COUNT is explicitely set
        #
        query = Protonym.is_species_or_genus_group
          .joins(:original_combination_relationships)
          .where(
            project_id: @args[:project_id],
            cached_original_combination: nil)

        puts Rainbow("Processing #{query.count} records").purple

        cached_rebuild_processes = ENV['cached_rebuild_processes'] ? ENV['cached_rebuild_processes'].to_i : 16

        Parallel.each(query.find_each, progress: 'update_cached_original_combinations', in_processes: cached_rebuild_processes ) do |n|
          begin
            n.update_cached_original_combinations
          rescue => exception
            puts Rainbow(" FAILED #{exception}").red.bold
            puts Rainbow(" FAILED #{exception}").red.bold
          end
          true
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
          true
        end
      end
    end

  end
end


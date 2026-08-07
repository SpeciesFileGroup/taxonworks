namespace :tw do
  namespace :maintenance do
    namespace :identifiers do

      # This should in theory only be necessary once, post migration 20221101203023_add_cached_numeric_identifier_to_identifier.rb
      # export PARALLEL_PROCESSOR_COUNT=8 && rake tw:maintenance:identifiers:rebuild_identifiers_cache
      desc 'rebuild all cached values in *local* identifiers'
      task rebuild_identifiers_cache: [:environment] do |t|
        Parallel.each(Identifier::Local.find_each(batch_size: 500), progress: 'rebuilding identifier cache', in_processes: ENV['PARALLEL_PROCESSOR_COUNT'].to_i || 0) do |i|
          begin
            i.send(:set_cached)
          rescue => exception
            puts "Error - id: #{i.id}"
          end
        end
        puts Rainbow("Reindex complete.").yellow
      end

      # This should in theory only be necessary once per class of data, after Shared::AutoUuid was implemented
      # export PARALLEL_PROCESSOR_COUNT=4 && rake tw:maintenance:identifiers:assign_auto_uuid_where_required
      desc 'assign auto_uuid where required'
      task assign_auto_uuid_where_required: [:environment] do |t|

        ApplicationEnumeration.superclass_models.each do |k|
          next unless k.respond_to?(:auto_uuids?) && k.auto_uuids?

          puts

          puts k.name
          missing = k.where.missing(:uuids)
          puts 'Present: ' + k.joins(:uuids).count.to_s
          puts 'Missing: ' + missing.count.to_s

          Parallel.each(missing.find_each(batch_size: 500), progress: 'adding auto_uuids', in_processes: ENV['PARALLEL_PROCESSOR_COUNT'].to_i || 0) do |o|
            begin
              o.send(:create_object_uuid)
            rescue => exception
              puts "Error - id: #{o.id} #{exception}"
            end
          end

          puts
        end

        puts Rainbow("Auto UUID additions complete.").yellow
      end

    end
  end
end


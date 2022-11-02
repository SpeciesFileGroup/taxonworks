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

    end
  end
end


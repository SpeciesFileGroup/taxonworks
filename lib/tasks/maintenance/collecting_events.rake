namespace :tw do
  namespace :maintenance do
    namespace :collecting_events do

      #  # Removed from CollectingEvent
      #  # @return [Boolean] always true
      #  #   A development method only. Attempts to create a verbatim georeference for every
      #  #   collecting event record that doesn't have one.
      #  #   TODO: this needs to be in a curate rake task or somewhere else
      #  def self.update_verbatim_georeferences
      #    if Rails.env == 'production'
      #      puts "You can't run this in #{Rails.env} mode."
      #      exit
      #    end

      #    passed = 0
      #    failed = 0
      #    attempted = 0

      #    CollectingEvent.includes(:georeferences).where(georeferences: {id: nil}).each do |c|
      #      next if c.verbatim_latitude.blank? || c.verbatim_longitude.blank?
      #      attempted += 1
      #      g = c.generate_verbatim_data_georeference(true)
      #      if g.errors.empty?
      #        passed += 1
      #        puts "created for #{c.id}"
      #      else
      #        failed += 1
      #        puts "failed for #{c.id}, #{g.errors.full_messages.join('; ')}"
      #      end
      #    end
      #    puts "passed: #{passed}"
      #    puts "failed: #{failed}"
      #    puts "attempted: #{attempted}"
      #    true
      #  end

      # export PARALLEL_PROCESSOR_COUNT=2 && rake tw:maintenance:collecting_events:tested_reindex_geographic_name_cached_values
      desc 'check cached geographic names and re-index where ncessary'
      task tested_reindex_geographic_name_cached_values: [:environment] do |t|
        updated = 0

        puts Rainbow('Using ' + ENV['PARALLEL_PROCESSOR_COUNT'].to_s + 'processors.').yellow 

        GC.start
        Parallel.each(CollectingEvent.find_each, progress: 'testing_and_indexing_collecting_events', in_processes: ENV['PARALLEL_PROCESSOR_COUNT'].to_i || 0) do |ce|
          begin
            a = {
              country: ce.cached_level0_geographic_name,
              state: ce.cached_level1_geographic_name,
              county: ce.cached_level2_geographic_name,
            }.delete_if{|k,v| v.nil?}

            b = ce.get_geographic_name_classification

            if a !=b
              updated +=1
              ce.update_columns(
                cached_level0_geographic_name: b[:country],
                cached_level1_geographic_name: b[:state],
                cached_level2_geographic_name: b[:county],
              )

              if updated != 0 && (updated % 100 == 0)
                puts "Updated: #{updated}"
              end
            end
          rescue => exception
            puts "Error - id: #{ce.id}"
          end
        end
        puts Rainbow("Re-indexed #{updated} collecting event records.").yellow
      end

      desc 'reindex geographic name fields where necessary'
      task reindex_geographic_name_cached_values: [:environment] do |t|

        r = CollectingEvent
          .where(
            cached_level0_geographic_name: nil,
            cached_level1_geographic_name: nil,
            cached_level2_geographic_name: nil,
          )
          .where.not(geographic_area_id: nil)

        puts Rainbow("Indexing geographic names for #{r.count} collecting event records :").yellow

        r.each_with_index do |c ,i|
          print "\r\r\r\r\r\r\r\r\r\r#{i}"
          c.send(:set_cached_geographic_names)
          #  puts c.geographic_area.name, c.geographic_area.id
        end
      end

    end
  end
end



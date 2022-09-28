namespace :tw do
  namespace :maintenance do
    namespace :collecting_events do

      desc 'check cached geographic names and re-indx where ncessary'
      task tested_reindex_geographic_name_cached_values: [:environment] do |t|
        updated = 0

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
            end
            if updated != 0 && (updated % 100 == 0)
              puts "Updated: #{updated}"
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



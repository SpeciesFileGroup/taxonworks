namespace :tw do
  namespace :maintenance do
    namespace :collecting_events do

      desc 'index geographic name fields where necessary'
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



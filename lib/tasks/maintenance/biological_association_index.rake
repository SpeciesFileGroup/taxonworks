namespace :tw do
  namespace :maintenance do
    namespace :biological_association_index do
      desc 'Populate biological_association_index for existing biological associations'
      task populate: [:environment] do
        puts "Counting biological associations without index..."
        total = BiologicalAssociation.where.missing(:biological_association_index).count
        puts "Found #{total} biological associations to index"

        if total == 0
          puts "Nothing to do!"
          next
        end

        count = 0
        start_time = Time.current

        BiologicalAssociation
          .where.missing(:biological_association_index)
          .includes(
            :biological_association_subject,
            :biological_association_object,
            :subject_biological_properties,
            :object_biological_properties,
            :sources,
            :notes,
            :identifiers,
            { biological_relationship: :uris }
          )
          .find_each do |ba|
            ba.no_biological_association_index = true
            ba.set_biological_association_index
            count += 1

            if count % 1_000 == 0
              elapsed = Time.current - start_time
              rate = count / elapsed
              remaining = total - count
              eta_seconds = remaining / rate

              # Format remaining time as hours:minutes:seconds
              hours = (eta_seconds / 3600).to_i
              minutes = ((eta_seconds % 3600) / 60).to_i
              seconds = (eta_seconds % 60).to_i
              eta_formatted = format('%02d:%02d:%02d', hours, minutes, seconds)

              puts "Progress: #{count}/#{total} (#{(count.to_f / total * 100).round(1)}%) - " \
                   "Rate: #{rate.round(1)}/sec - " \
                   "ETA: #{eta_formatted}"
            end
          end

        elapsed = Time.current - start_time
        puts "\nCompleted! Populated #{count} index records in #{elapsed.round(1)} seconds"
      end

      desc 'Remove all biological_association_index records'
      task clear: [:environment] do
        puts "Removing all biological_association_index records..."
        count = BiologicalAssociationIndex.count
        BiologicalAssociationIndex.delete_all
        puts "Removed #{count} index records"
      end
    end
  end
end

namespace :tw do

  # Tasks that auto-curate data
  namespace :maintenance do

    namespace :dwc_occurrences do

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

      desc 'Index collection objects into dwc_occurrence records, no updating of old, only new record creation'
      task build: [:environment] do |t|
        if ENV['total']
          total = ENV['total'].to_i
        else
          total = 500
        end

        records = CollectionObject.includes(:dwc_occurrence).where(dwc_occurrences: {id: nil}).limit(total)
        puts Rainbow("Processing maximum #{total} collection objects into dwc_occurence records.").yellow
        i = 0

        records.order(:id).limit(total).find_each do |o|
          begin
            print " id: #{o.id} - "
            print Benchmark.measure{z = o.get_dwc_occurrence}.to_s
            i += 1
          rescue
            puts Rainbow('Error, record #{o.id} not written.').red.bold
            raise
          end
        end

        puts Rainbow("Processed #{i} records.").yellow
      end

      desc 'Re-Index collection objects into dwc_occurrence records, all objects, with our without dwc_occcurrences'
      task rebuild: [:environment, :project_id] do |t|
        if ENV['total']
          total = ENV['total'].to_i
        else
          total = 500
        end

        records = CollectionObject.where(project_id: @args[:project_id]).limit(total)
        puts Rainbow("Processing maximum #{total} collection objects into dwc_occurence records.").yellow
        i = 0

        records.order(:id).limit(total).find_each do |o|
          print "  - id: #{o.id} ---  #{i} \r\r\r\r\r"
          # print Benchmark.measure{
          begin
            z = o.set_dwc_occurrence
          rescue RGeo::Error::InvalidGeometry => e
            puts Rainbow("Error [#{o.id}] bad geometry not written. #{e}").red.bold
          #rescue => e
          #  puts Rainbow("Error (other) [#{o.id}] record not written. #{e}").red.bold
          end
          i = i + 1
        end

        puts Rainbow("Processed #{i} records.").yellow
      end

    end
  end
end

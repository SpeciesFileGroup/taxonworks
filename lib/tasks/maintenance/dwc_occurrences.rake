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

      # nohup rake tw:maintenance:dwc_occurrences:build total=1500000 &
      desc 'Index CollectionObjects into dwc_occurrence records, no updating of old, only new record creation'
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

      desc 'Reindex CollectionObjects into dwc_occurrence records, all objects, with our without dwc_occcurrences, for a project'
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

      # nohup export PARALLEL_PROCESSOR_COUNT=4 && rake tw:maintenance:dwc_occurrences:rebuild_asserted_distributions total=1500000 project_id=16 &
      desc 'Reindex AssertedDistribution into dwc_occurrence records, all objects, with our without dwc_occcurrences'
      task rebuild_asserted_distributions: [:environment] do |t|
        if ENV['total']
          total = ENV['total'].to_i
        else
          total = 500
        end

        if ENV['project_id']
          project_id = ENV['project_id'].to_i
        end

        if ENV['taxon_name_id']
          taxon_name_id = ENV['taxon_name_id'].to_i
        end

        records = AssertedDistribution.limit(total)
        records = records.where(project_id: project_id) if project_id
        records = records.joins(otu: [:taxon_name]).where(otus: {taxon_name: TaxonName.with_ancestor(TaxonName.find(taxon_name_id))} ) if taxon_name_id

        index_asserted_distributions(records)

        puts Rainbow("Processed #{records.count} records.").yellow
      end

      # nohup export PARALLEL_PROCESSOR_COUNT=4 && rake tw:maintenance:dwc_occurrences:rebuild_asserted_distributions total=1500000 project_id=16 taxon_name_id=455472 &
      desc 'Reindex AssertedDistribution into dwc_occurrence records, without dwc_occcurrences'
      task build_asserted_distributions: [:environment] do |t|
        if ENV['total']
          total = ENV['total'].to_i
        else
          total = 500
        end

        if ENV['project_id']
          project_id = ENV['project_id'].to_i
        end

        if ENV['taxon_name_id']
          taxon_name_id = ENV['taxon_name_id'].to_i
        end

        records = AssertedDistribution.where.missing(:dwc_occurrence).limit(total)
        records = records.where(project_id: project_id) if project_id
        records = records.joins(otu: [:taxon_name]).where(otus: {taxon_name: TaxonName.with_ancestor(TaxonName.find(taxon_name_id))} ) if taxon_name_id

        index_asserted_distributions(records)

        puts Rainbow("Done. Processed all records.").yellow
      end

      def index_asserted_distributions(records)
        puts Rainbow("Processing maximum #{records.count} AssertedDistributions into dwc_occurence records (on #{ENV['PARALLEL_PROCESSOR_COUNT']} processors).").yellow

        GC.start
        Parallel.each(records.find_each, progress: 'set_dwc_occurrence', in_processes: ENV['PARALLEL_PROCESSOR_COUNT'].to_i || 0) do |asserted_distribution|
          begin
            asserted_distribution.set_dwc_occurrence
          rescue => exception
            puts "Error - id: #{asserted_distribution.id}"
          end
        end

      end

    end
  end
end

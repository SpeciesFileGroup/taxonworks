namespace :tw do

  # Tasks that auto-curate data
  namespace :maintenance do

    namespace :dwc_occurrences do

      # nohup export PARALLEL_PROCESSOR_COUNT=2 && rake tw:maintenance:dwc_occurrences:build total=150 &
      desc 'Index CollectionObjects into dwc_occurrence records, no updating of old, only new record creation'
      task build: [:environment] do |t|
        if ENV['total']
          total = ENV['total'].to_i
        else
          total = 500
        end

        records = CollectionObject.includes(:dwc_occurrence).where(dwc_occurrences: {id: nil}).limit(total).order(:id)
        puts Rainbow("Processing maximum #{total} collection objects into dwc_occurence records.").yellow

        index_collection_objects(records)
      end

      desc 'Reindex CollectionObjects into dwc_occurrence records, all objects, with our without dwc_occcurrences, for a project'
      task rebuild: [:environment, :project_id] do |t|
        if ENV['total']
          total = ENV['total'].to_i
        else
          total = 500
        end

        records = CollectionObject.where(project_id: @args[:project_id]).order(:id).limit(total)
        puts Rainbow("Processing maximum #{total} collection objects into dwc_occurence records.").yellow
        
        index_collection_objects(records)
      end

      # nohup export PARALLEL_PROCESSOR_COUNT=4 && bundle exec rake tw:maintenance:dwc_occurrences:rebuild_asserted_distributions total=1500000 project_id=16 &
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

      private 

      def index_asserted_distributions(records)
        puts Rainbow("Processing maximum #{records.count} AssertedDistributions into dwc_occurence records (on #{ENV['PARALLEL_PROCESSOR_COUNT'] || 1} processors).").yellow

        GC.start
        Parallel.each(records.find_each, progress: 'set_dwc_occurrence', in_processes: ENV['PARALLEL_PROCESSOR_COUNT'].to_i || 0) do |asserted_distribution|
          begin
            asserted_distribution.set_dwc_occurrence
          rescue => exception
            puts "Error - id: #{asserted_distribution.id}"
          end
        end
      end

      def index_collection_objects(records)
        puts Rainbow("Processing maximum #{records.count} CollectionObjects into DwcOccurrence records (on #{ENV['PARALLEL_PROCESSOR_COUNT' || 1]} processors).").yellow

        GC.start
        Parallel.each(records.find_each, progress: 'set_dwc_occurrence', in_processes: ENV['PARALLEL_PROCESSOR_COUNT'].to_i || 0) do |collection_object|
          begin
            collection_object.set_dwc_occurrence
          rescue => exception
            puts "Error - id: #{collection_object.id}"
          end
        end
      end

    end
  end
end

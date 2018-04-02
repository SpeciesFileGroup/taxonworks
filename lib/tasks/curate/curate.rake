namespace :tw do

  # Tasks that auto-curate data
  namespace :curate do

    desc 'Index collection objects into dwc_occurrence records, no updating, only creation'
    task build_dwc_occurrences: [:environment] do |t|
      if ENV['total'] 
        total = ENV['total'].to_i
      else
        total = 500
      end 

      records = CollectionObject.includes(:dwc_occurrence).where(dwc_occurrences: {id: nil}).limit(total)
      puts Rainbow("Processing maximum #{total} collection objects into dwc_occurence records.").yellow
      i = 0

      begin
        records.order(:id).limit(total).in_groups_of(20, false) do |group|
          ApplicationRecord.transaction do
            print Rainbow("Writing\n").bold
            group.each do |o|
              z = o.get_dwc_occurrence
              print " id: #{o.id}\n"
              i += 1
            end
            print Rainbow("...saved.\n").bold
          end
        end
      rescue
        puts Rainbow('Error, current batch of 20 records not written.').red.bold
        raise
      end

      puts Rainbow("Processed #{i} records.").yellow
    end

    desc 'Re-calculate the boundaries for Sqed depictions'
    task recalculate_sqed_boundaries: [:environment, :project_id] do |t|
      project_id = ENV['project_id']

      a = SqedDepiction.where(project_id: project_id).order(:id)
      id_min = a.first.try(:id)
      id_max = a.last.try(:id)

      puts Rainbow("id range for project #{project_id} is #{id_min}-#{id_max}.").blue

      if ENV['id_start'].nil? || ENV['id_end'].nil?
        puts Rainbow("Must set id_start= and id_end=").red
      end

      min_id = ENV['id_start'].to_i
      max_id = ENV['id_end'].to_i

      records = a.where('id > ?', min_id - 1).where('id < ?', max_id + 1)

      puts Rainbow("Processing #{records.count} sqed_depictions.").blue

      i = 0
      begin
        records.order(:id).in_groups_of(20, false) do |group|
          ApplicationRecord.transaction do
            print Rainbow("Writing\n").bold
            group.each do |o|
              o.preprocess
              print " id: #{o.id}\n"
              i += 1
            end
            print Rainbow("...saved.\n").bold
          end
        end
      rescue
        puts Rainbow('Error, current batch of 20 records not written.').red.bold
        raise
      end
    end

  end
end

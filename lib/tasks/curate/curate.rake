namespace :tw do

  # Tasks that auto-curate data
  namespace :curate do

    desc "Index collection objects into dwc_occurrence records, no updating, only creation"
    task :build_dwc_occurrences => [:environment] do |t|
      if ENV['total'] 
        total = ENV['total'].to_i
      else
        total = 500
      end 

      records = CollectionObject.includes(:dwc_occurrence).where(dwc_occurrences: {id: nil}).limit(total)

      puts Rainbow("Processing maxixum #{total} collection objects into dwc_occurence records.").yellow

      i = 0

      begin
        records.order(:id).limit(total).in_groups_of(20, false) do |group|
          ActiveRecord::Base.transaction do
            print Rainbow("Writing\n").bold
            group.each do |o|
              z = o.get_dwc_occurrence
              print " id: #{o.id} - #{z.id}\n"
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
  end
end

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
    task recalculate_sqed_boundaries: [:environment, :project_id, :id_start, :id_end] do |t|
      project_id = ENV['project_id']

      a = SqedDepiction.where(project_id: project_id).order(:id)
      id_min = a.first.try(:id)
      id_max = a.last.try(:id)

      puts Rainbow("id range for project #{project_id} is #{id_min}-#{id_max}.").blue

      records = a.where('id > ?', @args[:id_start] - 1).where('id < ?', @args[:id_end] + 1)

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

    desc 'Rotate images'
    task rotate_images: [:environment, :project_id, :user_id, :id_start, :id_end] do |t|
      raise TaxonWorks::Error, Rainbow('Specify rotate, like rotate=180').yellow if ENV['rotate'].blank?
      rotate = ENV['rotate'].to_i

      a = Image.where(project_id: @args[:project_id]).order(:id)

      records = a.where('id > ?', @args[:id_start] - 1).where('id < ?', @args[:id_end] + 1)

      puts Rainbow("Processing #{records.count} images.").blue

      i = 0

      begin
        print Rainbow("Rotating\n").bold
        records.order(:id).find_each do |i|
          ApplicationRecord.transaction do
            original_file = i.image_file.path(:original)
            puts Rainbow(i.id.to_s + ': ' + original_file).purple

            temp_original = original_file + '.tmp'

            FileUtils.cp(original_file, temp_original)

            begin
              j = Magick::Image::read(original_file).first

              jr = j.rotate(rotate)

              File.delete(original_file)
              jr.write(original_file)
            rescue
              FileUtils.cp(temp_original, original_file)
              raise
            ensure
              File.delete(temp_original) if File.exists?(temp_original)
            end

            i.image_file.reprocess!
          rescue
            raise
          end
        end
      end
    end
  end
end

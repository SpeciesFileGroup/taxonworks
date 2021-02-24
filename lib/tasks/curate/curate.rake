namespace :tw do

  # Tasks that auto-curate data
  namespace :curate do

 #  # Removed from ColelctingEvent 
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

      all = ENV['tw_sqed_calculate_all'] == 'true' ? true : false

      a = SqedDepiction.where(project_id: project_id).order(:id)

      a = a.where(result_boundary_coordinates: nil) unless all

      id_min = a.first.try(:id)
      id_max = a.last.try(:id)

      puts Rainbow("id range (all: #{all}) for project #{project_id} is #{id_min}-#{id_max}.").blue
      records = a.where('id > ?', @args[:id_start] - 1).where('id < ?', @args[:id_end] + 1)
      puts Rainbow("Processing #{records.count} sqed_depictions.").blue

      i = 0

      records.order(:id).in_groups_of(3, false) do |group|
        ApplicationRecord.transaction_with_retry do
          begin
            print Rainbow("Writing\n").bold
            group.each do |o|
              o.preprocess
              print " id: #{o.id}\n"
              i += 1
            end
            print Rainbow("...saved.\n").bold

          rescue RuntimeError => e
            puts Rainbow("Error: #{e}. Current batch of 3 records not written, skipping.").red.bold
            next
          end
        end
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

              j.destroy! # free memory/cache
              
              File.delete(original_file)
              jr.write(original_file)
              jr.destroy! # free memory/cache
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

namespace :tw do
  namespace :batch_load do
    namespace :sqed_depiction do

      # rake tw:batch_load:sqed_depiction:preprocess total=10 
      desc 'preprocess the first <total> sqed depictions that do not have both OCR and boundaries populated in cache, does not care what project the data are in'
      task preprocess: [:environment] do |t|
        if ENV['total'] 
          total = ENV['total'].to_i
        else
          total = 10 
        end 

        i = 0

        puts 'Processing empty sqed depictions'.yellow

        while i < total
          print "\r #{i}"
          break if SqedDepiction.preprocess_empty(1) != 1
          i += 1
        end
        puts
        puts "Processed #{i} records.".yellow
      end


      # Basic format: 
      #   rake tw:batch_load:sqed_depiction:import total=1 data_directory=/Users/matt/Desktop/images/ project_id=1 user_id=1 
      # Extended format:
      #   rake tw:batch_load:sqed_depiction:import total=1 layout=cross metada_map="{"0": "curator_metadata", "1": "identifier", "2": "image_registration", "3": "annotated_specimen"}" boundary_Finder='Sqed::BoundaryFinder::ColorLineFinder' data_directory=/Users/matt/Desktop/images/ preprocess_result=false project_id=1 user_id=1 
      desc 'import collection object depictions'
      task import: [:environment, :project_id, :user_id, :data_directory] do |t|

        # These match sqed and sqed_depiction extraction_metadata patterns
        @args.merge!(boundary_color: (ENV['boundary_color'] || 'green'))
        @args.merge!(boundary_finder: (ENV['boundary_finder'] || 'Sqed::BoundaryFinder::ColorLineFinder'))
        @args.merge!(has_border: (ENV['has_border'] || 'false'))
        @args.merge!(layout: (ENV['layout'] || 'cross'))
        @args.merge!(metadata_map: (ENV['metadata_map'] || '{"0": "curator_metadata", "1": "identifier", "2": "image_registration", "3": "annotated_specimen"}'))

        # Stored in/defines the CollectionObject instance
        @args.merge!(total: (ENV['total'] || '1'))

        # coerce some types from text
        @args[:metadata_map] = JSON.parse(@args[:metadata_map]).inject({}){|hsh, i| hsh.merge(i[0].to_i => i[1].to_sym)} 
        @args[:has_border] = (@args[:has_border] == 'true' ? true : false)
        @args[:boundary_color] = @args[:boundary_color].to_sym

        puts "Using attributes:".yellow.bold
        print @args

        puts "\nProcessing images: \n".yellow.bold

        begin
          Dir.glob(@args[:data_directory] + "**/*.*").in_groups_of(20, false) do |group| 
            ActiveRecord::Base.transaction do 
              group.each do |f|
                print f.blue + ": "

                if SqedDepiction.joins(:image).where(images: {image_file_fingerprint: Digest::MD5.file(f).hexdigest }, project_id: $project_id).any?
                  print "exists as depiction, skipping\n".purple.bold
                  next
                end

                image = Image.new(image_file: File.open(f))
                collection_object = CollectionObject.new(total: @args[:total])

                sqed_depiction = SqedDepiction.new(
                  layout: @args[:layout],
                  metadata_map: @args[:metadata_map],
                  boundary_finder: @args[:boundary_finder],
                  has_border: @args[:has_border],
                  boundary_color: @args[:boundary_color],

                  depiction_attributes: { 
                    image: image,
                    depiction_object: collection_object
                  }
                )

                if sqed_depiction.valid?
                  sqed_depiction.save!
                  print "success\n"

                  unless ENV['preprocess_result'] == 'false'
                    sqed_depiction.preprocess
                  end 

                else
                  print(" failed, skipping - " + sqed_depiction.errors.full_messages.join("; ").red + "\n")
                end
              end

              puts "group handled".yellow.bold
            end # end transaction
          end

        rescue ActiveRecord::RecordInvalid
          raise 'transaction aborted, this groups records not stored.'
        end
      end

    end
  end
end

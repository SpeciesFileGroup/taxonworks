#require 'io/console'
# require 'fileutils'

namespace :tw do
  namespace :batch_load do
    namespace :sqed_depiction do

      # rake tw:batch_load:sqed_depiction:import layout="cross" layout="foo" total=1 boundary_finder="bar"  data_directory=/Users/matt/Desktop/images/ project_id=1 user_id=1 
      # 

      # Basic format: 
      #   rake tw:batch_load:sqed_depiction:import total=1 data_directory=/Users/matt/Desktop/images/ project_id=1 user_id=1 
      # Extended format:
      #   rake tw:batch_load:sqed_depiction:import total=1 layout=cross metada_map="{"0": "curator_metadata", "1": "identifier", "2": "image_registration", "3": "annotated_specimen"}" boundary_Finder='Sqed::BoundaryFinder::ColorLineFinder' data_directory=/Users/matt/Desktop/images/ project_id=1 user_id=1 
      #
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

        puts "Processing images: ".yellow.bold
        ActiveRecord::Base.transaction do 
          begin
            i = 0
            Dir.glob(@args[:data_directory] + "**/*.*") do |f| 
              print f.blue + ": "
              i += 1 
              # break if i == 5

              image = File.open(f)

              collection_object = CollectionObject.new(total: @args[:total])

              sqed_depiction = SqedDepiction.new(
                layout: @args[:layout],
                metadata_map: @args[:metadata_map],
                boundary_finder: @args[:boundary_finder],
                has_border: @args[:has_border],
                boundary_color: @args[:boundary_color],

                depiction_attributes: { 
                  image_attributes: {
                    image_file: image 
                  },
                  depiction_object: collection_object
                }
              )

              if sqed_depiction.valid?
                sqed_depiction.save!
                print " success\n"
              else
                print(" failed, skipping - " + sqed_depiction.errors.full_messages.join("; ").red + "\n")
              end
            end
            puts "Done.".yellow.bold
          rescue ActiveRecord::RecordInvalid
            raise
          end

        end # end transaction

      end
    end
  end
end


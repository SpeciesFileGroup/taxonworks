namespace :tw do
  namespace :batch_load do
    namespace :documentations do
      
      # Format
      #   rake tw:batch_load:documentations data_directory="/chromatograms/" meta_data_file="/chromatograms.csv project_id=1 user_id=2"
      # 
      # The expected format for the meta data file is to be tab delimitted with 3 columns of "namespace_short_name", "identifier", and "filenames"
      # namespace_short_name contains the short name of the namespace
      # identifier contains the text of the identifier
      # filenames contains the filenames of the files to be attached, multiple files can be in this field if separated by a ", "
      desc '
        Imports files in the filenames column as documents and attaches 
        them to the first object identified by the namespace_short_name 
        and identifer column via documentations 
      '
      task :import => [:environment, :project_id, :user_id] do
        data_directory_path = ENV["data_directory"]
        meta_data_file_path = ENV["meta_data_file"]

        raise "Path to data directory not provided".red if data_directory_path.nil?
        raise "Data directory does not exist at #{data_directory_path}".red unless File.directory?(data_directory_path)
        raise "Path to meta data file not provided".red if meta_data_file_path.nil?
        raise "Meta data file does not exist at #{meta_data_file_path}".red unless File.exists?(meta_data_file_path)

        csv = CSV.parse(File.read(meta_data_file_path), { headers: true, col_sep: "\t" })

        puts "Processing files".yellow
        documentations_created = 0

        csv.each do |row|
          namespace_short_name = row["namespace_short_name"]
          identifier = row["identifier"]
          filenames = row["filenames"].split(", ")
          
          identifier_objects = Identifier.where(cached: "#{namespace_short_name} #{identifier}")
          identifier_object = nil
          identifier_object = identifier_objects.first.identifier_object if identifier_objects.any?

          if !identifier_object.nil?
            filenames.each do |filename|
              file_path = File.join(data_directory_path, filename)

              if File.exists?(file_path)
                document = Document.new(document_file: File.open(file_path))
                document.save!

                documentation = Documentation.new(document: document, documentation_object: identifier_object)
                documentation.save!
                documentations_created += 1
              else
                puts "File #{file_path} does not exist".green
              end
            end
          end
        end

        puts "Finished processing files".yellow
        puts "Created #{documentations_created} documentations".green
      end
    end
  end
end

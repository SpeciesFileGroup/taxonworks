namespace :tw do
  namespace :batch_load do
    namespace :documentations do

      # Format
      #   rake tw:batch_load:documentations data_directory="/chromatograms/" meta_data_file="/chromatograms.csv project_id=1 user_id=2"
      #
      # The expected format for the meta data file is to be tab delimitted with 2 columns of "identifier" and "filenames"
      # identifier contains the namespace short name and text of the identifier e.g. "DRM 12345"
      # filenames contains the filenames of the files to be attached, multiple files can be in this field if separated by a ", "
      desc '
        Imports files in the filenames column as documents and attaches
        them to the first object identified by the namespace_short_name
        and identifer column via documentations
      '
      task import: [:environment, :project_id, :user_id] do
        data_directory_path = ENV['data_directory']
        meta_data_file_path = ENV['meta_data_file']
        transaction_total = ENV['transaction_total'] || 20

        raise 'Path to data directory not provided'.red if data_directory_path.nil?
        raise "Data directory does not exist at #{data_directory_path}".red unless File.directory?(data_directory_path)
        raise 'Path to meta data file not provided'.red if meta_data_file_path.nil?
        raise "Meta data file does not exist at #{meta_data_file_path}".red unless File.exist?(meta_data_file_path)

        csv = CSV.parse(File.read(meta_data_file_path), { headers: true, col_sep: "\t" })

        puts Rainbow('Processing files').yellow
        documents_created = 0
        documentations_created = 0
        rows_processed = 0

        csv.each_slice(transaction_total) do |row_group|
          begin
            ApplicationRecord.transaction do
              row_group.each do |row|
                rows_processed += 1
                identifier_text = row['identifier']
                filenames = row['filenames'].split(', ')
                identifier = Identifier.find_by(cached: identifier_text)

                if identifier.nil?
                  puts Rainbow("Object with identifier \"#{identifier_text}\" not found on row #{rows_processed}").yellow
                else
                  identifier_object = identifier.identifier_object

                  filenames.each do |filename|
                    file_path = File.join(data_directory_path, filename)

                    if File.exist?(file_path)
                      # Check if the document already exists
                      document = Document.find_by(document_file_fingerprint: Digest::MD5.file(file_path).hexdigest)

                      # If document doesn't exist, create it
                      if document.nil?
                        document = Document.new(document_file: File.open(file_path))

                        if document.valid?
                          document.save!
                          documents_created += 1
                        else
                          puts Rainbow("Document invalid on row #{rows_processed} - #{document.errors.full_messages.join("; ")}").red
                        end
                      else
                        puts Rainbow("Document already exists on row #{rows_processed}").yellow
                      end

                      # If document exists and has been saved, create documentation with it
                      if !document.nil? && document.persisted?
                        # Check if documentation already exists with this rows document and identifier_object pair
                        documentation = Documentation.find_by(document: document, documentation_object: identifier_object)

                        # If documentation with this document/identifier_object pair doesn't exist, create it
                        if documentation.nil?
                          documentation = Documentation.new(document: document, documentation_object: identifier_object)

                          if documentation.valid?
                            documentation.save!
                            documentations_created += 1
                          else
                            puts Rainbow("Documentation invalid on row #{rows_processed} - #{documentation.errors.full_messages.join("; ")}").red
                          end
                        else
                          puts Rainbow("Documentation already exists with this document/identifier_object pair on row #{rows_processed}").yellow
                        end
                      end
                    else
                      puts Rainbow("File \"#{filename}\" not found on row #{rows_processed}").yellow
                    end
                  end
                end
              end
            end
          rescue ActiveRecord::RecordInvalid
            raise "Transaction aborted, this group of records not stored because row #{rows_processed} failed."
          end
        end

        puts Rainbow('Finished processing files').yellow
        puts Rainbow("Created #{documentations_created} documentations and #{documents_created} documents").green
      end
    end
  end
end

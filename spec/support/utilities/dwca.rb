module Spec
  module Support
    module Utilities
      module Dwca

        def self.extract_data_tsv_table(zip_path)
          content = ''
          Zip::File.open(zip_path) do |zip_file|
            zip_file.each do |entry|
              if entry.name == 'data.tsv' && entry.file?
                content = entry.get_input_stream.read
              end
            end
          end

          CSV.parse(content, col_sep: "\t", headers: true)
        end

        def self.extract_eml_file(zip_path)
          content = ''
          Zip::File.open(zip_path) do |zip_file|
            zip_file.each do |entry|
              if entry.name == 'eml.xml' && entry.file?
                content = entry.get_input_stream.read
              end
            end
          end

          Nokogiri::XML(content)
        end

      end
    end
  end
end
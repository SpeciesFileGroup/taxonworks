module Spec
  module Support
    module Utilities
      module Dwca

        def self.extract_tsv_file(zip_path, file_name)
          content = ''
          Zip::File.open(zip_path) do |zip_file|
            zip_file.each do |entry|
              if entry.name == file_name && entry.file?
                content = entry.get_input_stream.read
              end
            end
          end

          CSV.parse(content, col_sep: "\t", headers: true)
        end

        def self.extract_xml_file(zip_path, file_name)
          content = ''
          Zip::File.open(zip_path) do |zip_file|
            zip_file.each do |entry|
              if entry.name == file_name && entry.file?
                content = entry.get_input_stream.read
              end
            end
          end

          Nokogiri::XML(content)
        end

        def self.extract_data_tsv_table(zip_path)
          self.extract_tsv_file(zip_path, 'data.tsv')
        end

        def self.extract_eml_file(zip_path)
          self.extract_xml_file(zip_path, 'eml.xml')
        end

        def self.extract_media_tsv_table(zip_path)
          self.extract_tsv_file(zip_path, 'media.tsv')
        end

        def self.extract_resource_relationships_tsv_table(zip_path)
          self.extract_tsv_file(zip_path, 'resource_relationships.tsv')
        end

      end
    end
  end
end
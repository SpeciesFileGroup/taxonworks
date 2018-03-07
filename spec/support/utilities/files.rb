require 'prawn'

module Spec
  module Support
    module Utilities 
      module Files

        # @return [String]
        #   path to the generated pdf is generated and placed at the 
        # @param pages [Integer] number of pages to render
        # @param file_name [String] 
        # @param path [String] you likely shouldn't change this
        def self.generate_pdf(pages: 3, file_name: 'hello.pdf', path: Rails.configuration.x.test_tmp_file_dir)
          f = "#{path}hello.pdf"
          Prawn::Document.generate(f) do
            (1..pages).each do |p|
              start_new_page unless p == 1
              text "On the #{p.ordinalize} page."
            end
          end
          f
        end

      end
    end
  end
end

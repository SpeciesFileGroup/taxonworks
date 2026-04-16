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
          f = File.join(path, file_name)
          Prawn::Document.generate(f) do
            (1..pages).each do |p|
              start_new_page unless p == 1
              text "On the #{p.ordinalize} page."
            end
          end
          f
        end

        def self.generate_png(file_name: 'i.png', path: Rails.configuration.x.test_tmp_file_dir)
          f = File.join(path, file_name)
          a = ChunkyPNG::Image.new(1024, 1024, ChunkyPNG::Color::TRANSPARENT)
          a.line(1, 1, 10, 1, ChunkyPNG::Color.from_hex('#aa007f'))
          a[1,1] = ChunkyPNG::Color.rgba(10, 20, 30, 128)
          b = a.save(f, interlace: true)
          b.path
        end

        def self.generate_tiny_random_png(file_name: 'i.png', path: Rails.configuration.x.test_tmp_file_dir)
          f = File.join(path, file_name)
          a = ChunkyPNG::Image.new(16, 16, ChunkyPNG::Color::TRANSPARENT)
          a.line(1, 14, 14, 1, ChunkyPNG::Color.from_hex('#aa007f'))
          a[1,1] = ChunkyPNG::Color.rgba(rand(254), rand(254), rand(254), 128)
          b = a.save(f, interlace: true)
          b.path
        end

        def self.generate_tiny_random_sized_png(file_name: 'i.png', path: Rails.configuration.x.test_tmp_file_dir, x: 16, y: 16)
          f = File.join(path, file_name)
          a = ChunkyPNG::Image.new(x, y, ChunkyPNG::Color::TRANSPARENT)
          a.line(1, y - 1, x - 1, 1, ChunkyPNG::Color.from_hex('#aa007f'))
          a[1,1] = ChunkyPNG::Color.rgba(rand(254), rand(254), rand(254), 128)
          b = a.save(f, interlace: true)
          b.path
        end

      end
    end
  end
end

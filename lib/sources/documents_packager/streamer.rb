module Sources::DocumentsPackager
  class Streamer
    def document_source_available?(document)
      document_file_path(document).present?
    end

    def stream(entries:, zip_streamer:)
      zip_streamer.call do |zip|
        written = false
        used_names = {}

        entries.each_with_index do |document, idx|
          begin
            zip.write_deflated_file(document_entry_name(document, used_names)) do |sink|
              stream_document(document, sink)
            end
            written = true
          rescue StandardError => e
            Rails.logger.warn(
              "Documents packager: failed to stream document #{document.id}: #{e.class} #{e.message}"
            )
          end
        end

        unless written
          zip.write_deflated_file('errors.txt') do |sink|
            sink.write("No documents could be streamed for this package.\n")
          end
        end
      end
    end

    private

    def document_entry_name(document, used_names)
      base = document.document_file_file_name.presence || "document_#{document.id}"
      candidate = Zaru::sanitize!(base)
      return reserve_name(candidate, used_names) if used_names[candidate].nil?

      ext = File.extname(candidate)
      stem = File.basename(candidate, ext)
      disambiguated = "#{stem}-#{document.id}#{ext}"
      reserve_name(Zaru::sanitize!(disambiguated), used_names)
    end

    def reserve_name(name, used_names)
      final = name
      suffix = 1

      while used_names[final]
        suffix += 1
        ext = File.extname(name)
        stem = File.basename(name, ext)
        final = "#{stem}-#{suffix}#{ext}"
      end

      used_names[final] = true
      final
    end

    def stream_document(document, sink)
      path = document_file_path(document)
      raise "Document file missing for #{document.id}" if path.blank?

      File.open(path, 'rb') { |io| IO.copy_stream(io, sink) }
    end

    def document_file_path(document)
      path = document.document_file.path
      return path if path.present? && File.exist?(path)
      nil
    end
  end
end

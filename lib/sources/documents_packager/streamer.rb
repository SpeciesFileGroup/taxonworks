# Streams Source documents into a zip archive.
#
# Uses Export::ZipStreamer for the core streaming logic.
module Sources::DocumentsPackager
  class Streamer
    def initialize
      @zip_streamer = Export::ZipStreamer.new
    end

    def document_source_available?(document)
      @zip_streamer.file_available?(document) { |doc| file_path(doc) }
    end

    def stream(entries:, zip_streamer:)
      @zip_streamer.stream(
        entries: entries,
        zip_streamer: zip_streamer,
        file_path: ->(doc) { file_path(doc) },
        file_name: ->(doc) { doc.document_file_file_name },
        entry_id: ->(doc) { doc.id },
        logger_prefix: 'Documents packager'
      )
    end

    private

    def file_path(document)
      path = document.document_file.path
      return path if path.present? && File.exist?(path)
      nil
    end
  end
end

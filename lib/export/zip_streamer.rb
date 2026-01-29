# Streams files into a zip archive with filename disambiguation.
#
# This class provides generic zip streaming functionality that can be used
# by any file packager (documents, images, etc.).
#
# @example Basic usage
#   streamer = Export::ZipStreamer.new
#   streamer.stream(
#     entries: documents,
#     zip_streamer: method(:zip_tricks_stream),
#     file_path: ->(doc) { doc.document_file.path },
#     file_name: ->(doc) { doc.document_file_file_name },
#     entry_id: ->(doc) { doc.id }
#   )
#
# @example Check file availability
#   streamer.file_available?(document) { |doc| doc.document_file.path }
#
# Authored with assistance from Claude (Anthropic)
module Export
  class ZipStreamer
    # Checks if a file is available on disk.
    #
    # @param entry [Object] the entry to check
    # @yield [entry] block that returns the file path for the entry
    # @return [Boolean] true if file exists and is readable
    def file_available?(entry, &file_path_extractor)
      path = extract_file_path(entry, &file_path_extractor)
      path.present?
    end

    # Streams entries into a zip archive.
    #
    # @param entries [Array] objects to stream
    # @param zip_streamer [#call] callable that yields a zip writer
    # @param file_path [Proc] extracts file path from entry
    # @param file_name [Proc] extracts original filename from entry
    # @param entry_id [Proc] extracts unique ID from entry (for disambiguation)
    # @param logger_prefix [String] prefix for log messages
    # @param on_entry [Proc, nil] optional callback (entry, filename, results) -> void
    # @param after_stream [Proc, nil] optional callback (zip, results, written) -> void
    def stream(entries:, zip_streamer:, file_path:, file_name:, entry_id:, logger_prefix: 'ZipStreamer', on_entry: nil, after_stream: nil)
      zip_streamer.call do |zip|
        written = false
        used_names = {}
        results = []

        entries.each do |entry|
          begin
            name = build_entry_name(
              entry,
              used_names,
              file_name: file_name,
              entry_id: entry_id
            )
            zip.write_deflated_file(name) do |sink|
              stream_file(entry, sink, file_path: file_path, entry_id: entry_id)
            end
            on_entry&.call(entry, name, results)
            written = true
          rescue StandardError => e
            Rails.logger.warn(
              "#{logger_prefix}: failed to stream entry #{entry_id.call(entry)}: #{e.class} #{e.message}"
            )
          end
        end

        after_stream&.call(zip, results, written)
        write_error_fallback(zip) unless written
      end
    end

    private

    def extract_file_path(entry, &file_path_extractor)
      path = file_path_extractor.call(entry)
      return path if path.present? && File.exist?(path)
      nil
    end

    def build_entry_name(entry, used_names, file_name:, entry_id:)
      base = file_name.call(entry).presence || "file_#{entry_id.call(entry)}"
      candidate = Zaru.sanitize!(base)
      return reserve_name(candidate, used_names) if used_names[candidate].nil?

      ext = File.extname(candidate)
      stem = File.basename(candidate, ext)
      disambiguated = "#{stem}-#{entry_id.call(entry)}#{ext}"
      reserve_name(Zaru.sanitize!(disambiguated), used_names)
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

    def stream_file(entry, sink, file_path:, entry_id:)
      path = file_path.call(entry)
      raise "File missing for entry #{entry_id.call(entry)}" if path.blank? || !File.exist?(path)

      File.open(path, 'rb') { |io| IO.copy_stream(io, sink) }
    end

    def write_error_fallback(zip)
      zip.write_deflated_file('errors.txt') do |sink|
        sink.write("No files could be streamed for this package.\n")
      end
    end
  end
end

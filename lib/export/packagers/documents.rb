# Prepares Source documents for batch download.
#
# Groups documents by size and provides preview data for the UI.
# Uses Export::FileGrouper for size-based grouping.
module Export
  module Packagers
    class Documents
      attr_reader :query_params, :project_id

      def initialize(query_params:, project_id:)
        @query_params = query_params
        @project_id = project_id
        @file_grouper = Export::FileGrouper.new
        @file_available_cache = {}
      end

      def preview(max_bytes:)
        return empty_preview if source_ids.empty?

        sources = sources_for_query
        table_documents = documents_for_sources(sources)
        unique_documents = unique_document_entries(table_documents)
        groups = group_entries(unique_documents, max_bytes)
        group_map = @file_grouper.build_group_map(
          groups: groups,
          id_extractor: ->(entry) { entry[:document].id }
        )

        {
          sources: serialize_sources(sources, table_documents, group_map),
          groups: serialize_groups(groups),
          total_documents: unique_documents.length
        }
      end

      def groups(max_bytes:)
        return [] if source_ids.empty?

        documents = unique_document_entries(documents_for_sources(sources_for_query))
        group_entries(documents, max_bytes)
      end

      def file_available?(document)
        document = document_from_entry(document)
        @file_available_cache.fetch(document.id) do
          path = document.document_file.path
          @file_available_cache[document.id] = path.present? && File.exist?(path)
        end
      end

      def stream(entries:, zip_streamer:, group_index:)
        Export::ZipStreamer.new.stream(
          entries: entries,
          zip_streamer: zip_streamer,
          file_path: ->(entry) { file_path(document_from_entry(entry)) },
          file_name: ->(entry) { document_from_entry(entry).document_file_file_name },
          entry_id: ->(entry) { document_from_entry(entry).id },
          logger_prefix: 'Documents packager',
          on_entry: method(:add_manifest_row),
          after_stream: ->(zip, rows, written) {
            write_manifest(zip, rows, written, group_index: group_index)
          }
        )
      end

      private

      def sources_for_query
        scope = Queries::Source::Filter.new(query_params).all
        scope = scope.joins(:project_sources)
          .where(project_sources: { project_id: project_id })

        ids = source_ids
        scope = scope.where(id: ids).order(:id)

        scope.includes(:documents)
      end

      def documents_for_sources(sources)
        documents = []
        index = 0

        sources.each do |source|
          source.documents
            .select { |document| document.project_id == project_id }
            .sort_by(&:id)
            .each do |document|
              index += 1
              documents << {
                source:,
                document:,
                index:
              }
            end
        end

        documents
      end

      def unique_document_entries(documents)
        documents.uniq { |entry| entry[:document].id }
      end

      def group_entries(documents, max_bytes)
        @file_grouper.group(
          items: documents,
          max_bytes: max_bytes,
          size_extractor: ->(entry) {
            file_available?(entry[:document]) ? entry[:document].document_file_file_size.to_i : 0
          }
        )
      end

      def serialize_sources(sources, documents, group_map)
        documents_by_source = documents.group_by { |entry| entry[:source].id }

        sources.map do |source|
          docs = documents_by_source[source.id] || []
          {
            id: source.id,
            cached: source.cached,
            documents: docs.map do |entry|
              document = entry[:document]
              {
                id: document.id,
                index: entry[:index],
                group_index: group_map[document.id],
                size: document.document_file_file_size.to_i,
                name: document.document_file_file_name,
                url: document.document_file.url(:original, false),
                available: file_available?(document)
              }
            end
          }
        end
      end

      def serialize_groups(groups)
        groups.map.with_index(1) do |group, index|
          available_entries = group.select { |entry| file_available?(entry[:document]) }
          {
            index:,
            size: available_entries.sum { |entry| entry[:document].document_file_file_size.to_i },
            document_ids: group.map { |entry| entry[:document].id },
            available_count: available_entries.length
          }
        end
      end

      def file_path(document)
        document = document_from_entry(document)
        path = document.document_file.path
        return path if path.present? && File.exist?(path)
        nil
      end

      def document_from_entry(entry)
        entry.is_a?(Hash) ? entry[:document] : entry
      end

      def add_manifest_row(entry, name, rows)
        return unless entry.is_a?(Hash)

        document = entry[:document]
        source = entry[:source]
        rows << [
          source&.id,
          document.id,
          name,
          document.document_file_file_size.to_i
        ]
      end

      def write_manifest(zip, rows, written, group_index:)
        return if !written || rows.empty?

        zip.write_deflated_file("documents-#{group_index}.tsv") do |sink|
          sink.write("source_id\tdocument_id\tzip_filename\tfile_size_bytes\n")
          rows.each do |row|
            sink.write("#{row.join("\t")}\n")
          end
        end
      end

      def source_ids
        Array(query_params[:source_id]).flatten.compact.map(&:to_i).uniq
      end

      def empty_preview
        {
          sources: [],
          groups: [],
          total_documents: 0
        }
      end
    end
  end
end

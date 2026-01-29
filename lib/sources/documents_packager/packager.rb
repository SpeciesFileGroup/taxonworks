module Sources::DocumentsPackager
  class Packager
    attr_reader :query_params, :project_id

    def initialize(query_params:, project_id:)
      @query_params = query_params
      @project_id = project_id
    end

    def preview(max_bytes:)
      return empty_preview if source_ids.empty?

      sources = sources_for_query
      table_documents = documents_for_sources(sources)
      unique_documents = unique_document_entries(table_documents)
      groups = group_documents(unique_documents, max_bytes)
      group_map = build_group_map(groups)

      {
        sources: serialize_sources(sources, table_documents, group_map),
        groups: serialize_groups(groups),
        total_documents: unique_documents.length
      }
    end

    def groups(max_bytes:)
      return [] if source_ids.empty?

      documents = unique_document_entries(documents_for_sources(sources_for_query))
      group_documents(documents, max_bytes)
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

    def group_documents(documents, max_bytes)
      groups = []
      current_group = []
      current_size = 0

      documents.each do |entry|
        size = entry[:document].document_file_file_size.to_i

        if current_group.any? && (current_size + size > max_bytes)
          groups << current_group
          current_group = []
          current_size = 0
        end

        current_group << entry
        current_size += size
      end

      groups << current_group if current_group.any?
      groups
    end

    def build_group_map(groups)
      group_map = {}

      groups.each_with_index do |group, index|
        group.each do |entry|
          group_map[entry[:document].id] = index + 1
        end
      end

      group_map
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
              available: document_file_path(document).present?
            }
          end
        }
      end
    end

    def serialize_groups(groups)
      groups.map.with_index(1) do |group, index|
        available_count = group.count { |entry| document_file_path(entry[:document]).present? }
        {
          index:,
          size: group.sum { |entry| entry[:document].document_file_file_size.to_i },
          document_ids: group.map { |entry| entry[:document].id },
          available_count:
        }
      end
    end

    def document_file_path(document)
      path = document.document_file.path
      return path if path.present? && File.exist?(path)
      nil
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

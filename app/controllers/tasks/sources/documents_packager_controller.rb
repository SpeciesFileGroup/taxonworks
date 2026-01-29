class Tasks::Sources::DocumentsPackagerController < ApplicationController
  include TaskControllerConfiguration
  include ZipTricks::RailsStreaming

  DEFAULT_MAX_BYTES = 50.megabytes
  MIN_MAX_BYTES = 1.megabyte
  MAX_MAX_BYTES = 500.megabytes

  before_action :set_query_params, only: [:preview, :download]

  # GET /tasks/sources/documents_packager
  def index
  end

  # POST /tasks/sources/documents_packager/preview.json
  def preview
    sources = sources_for_query(@query_params)
    table_documents = documents_for_sources(sources)
    unique_documents = unique_document_entries(table_documents)
    max_bytes = requested_max_bytes
    groups = group_documents(unique_documents, max_bytes)
    group_map = build_group_map(groups)

    render json: {
      sources: serialize_sources(sources, table_documents, group_map),
      groups: serialize_groups(groups),
      filter_params: @query_params,
      total_documents: unique_documents.length,
      max_bytes: max_bytes
    }
  end

  # GET /tasks/sources/documents_packager/download
  def download
    query_params = @query_params
    group_index = params[:group].to_i
    nickname = params[:nickname].to_s

    render json: { error: 'No sources queued.' }, status: :unprocessable_content and return if query_params.blank?

    max_bytes = requested_max_bytes
    sources = sources_for_query(query_params)
    documents = unique_document_entries(documents_for_sources(sources))
    groups = group_documents(documents, max_bytes)
    group = groups[group_index - 1]

    render json: { error: 'Group not found.' }, status: :not_found and return if group.blank?

    entries = group.map { |entry| entry[:document] }
    entries.select! { |document| document_source_available?(document) }

    render json: { error: 'No files available for this package.' }, status: :unprocessable_content and return if entries.empty?

    filename = build_zip_filename(nickname, group_index, groups.length)
    response.headers["Content-Disposition"] = "attachment; filename=\"#{filename}\""
    zip_tricks_stream do |zip|
      written = false

      entries.each_with_index do |document, idx|
        begin
          zip.write_deflated_file(document_entry_name(document, idx)) do |sink|
            stream_document(document, sink)
          end
          written = true
        rescue StandardError => e
          Rails.logger.warn("Documents packager: failed to stream document #{document.id}: #{e.class} #{e.message}")
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

  def set_query_params
    @query_params = params[:source_query].presence || params
    @query_params = @query_params.to_unsafe_h if @query_params.respond_to?(:to_unsafe_h)
    @query_params = @query_params.except(
      'controller',
      'action',
      'format',
      'group',
      'nickname',
      'max_mb',
      'authenticity_token',
      'token'
    )
  end

  def sources_for_query(query_params)
    scope = Queries::Source::Filter.new(query_params).all
    scope = scope.joins(:project_sources)
      .where(project_sources: { project_id: sessions_current_project_id })

    ids = Array(query_params[:source_id]).flatten.compact.map(&:to_i).uniq

    scope = if ids.any?
              scope.where(id: ids).order(Arel.sql(order_sources_by_ids(ids)))
            else
              scope.order(:cached)
            end

    scope.includes(:documents)
  end

  def order_sources_by_ids(ids)
    order = ids.each_with_index.map { |id, index| "WHEN #{id} THEN #{index}" }.join(' ')
    "CASE sources.id #{order} ELSE #{ids.length} END"
  end

  def documents_for_sources(sources)
    documents = []
    index = 0

    sources.each do |source|
      source.documents
        .select { |document| document.project_id == sessions_current_project_id }
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

  def requested_max_bytes
    mb = params[:max_mb].presence
    mb = mb.to_f if mb
    bytes = if mb && mb.positive?
              (mb * 1.megabyte).to_i
            else
              DEFAULT_MAX_BYTES
            end
    bytes.clamp(MIN_MAX_BYTES, MAX_MAX_BYTES)
  end

  def build_zip_filename(nickname, index, total)
    safe_nickname = nickname.presence || 'download'
    date = Time.zone.today.strftime('%-m_%-d_%y')
    Zaru::sanitize!("TaxonWorks-#{safe_nickname}-#{date}-#{index}_of_#{total}.zip").gsub(' ', '_')
  end

  def document_entry_name(document, index)
    base = document.document_file_file_name.presence || "document_#{document.id}"
    Zaru::sanitize!("#{index + 1}_#{document.id}_#{base}").gsub(' ', '_')
  end

  def document_source_available?(document)
    return true if document_file_path(document).present?
    document_remote_url(document).present?
  rescue StandardError
    false
  end

  def stream_document(document, sink)
    path = document_file_path(document)
    if path.present?
      File.open(path, 'rb') { |io| IO.copy_stream(io, sink) }
      return
    end

    url = document_remote_url(document)
    raise "Document file missing for #{document.id}" if url.blank?

    uri = URI.parse(url)
    uri = URI.join(request.base_url, uri) if uri.host.blank?

    download_to_stream(uri, sink)
  end

  def download_to_stream(uri, sink)
    ::Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)

      if response.is_a?(Net::HTTPRedirection) && response['location'].present?
        redirect_uri = URI.parse(response['location'])
        redirect_uri = URI.join(request.base_url, redirect_uri) if redirect_uri.host.blank?
        return download_to_stream(redirect_uri, sink)
      end

      unless response.is_a?(Net::HTTPSuccess)
        raise "HTTP #{response.code} for #{uri}"
      end

      response.read_body { |chunk| sink.write(chunk) }
    end
  end

  def document_file_path(document)
    path = document.document_file.path
    return path if path.present? && File.exist?(path)

    url = document.document_file.url(:original, false).to_s
    return nil if url.blank?

    url = url.split('?').first
    local_path = if url.start_with?('/')
                   url.delete_prefix('/')
                 else
                   URI.parse(url).path.delete_prefix('/')
                 end

    local = Rails.root.join('public', local_path).to_s
    File.exist?(local) ? local : nil
  rescue StandardError
    nil
  end

  def document_file_url(document)
    if document.document_file.respond_to?(:expiring_url)
      document.document_file.expiring_url(10.minutes.to_i, :original)
    else
      document.document_file.url(:original, false)
    end
  end

  def document_remote_url(document)
    url = document_file_url(document).to_s
    return nil if url.blank?

    uri = URI.parse(url)
    return nil if uri.host.blank?
    return nil if uri.host == request.host

    url
  rescue StandardError
    nil
  end
end

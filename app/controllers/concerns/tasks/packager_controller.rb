module Tasks
  module PackagerController
    extend ActiveSupport::Concern

    DEFAULT_MAX_MB = 100
    MIN_MAX_MB = 10
    MAX_MAX_MB = 1000

    private

    def set_query_params_for(key)
      @query_params = params[key].presence || params
      @query_params = @query_params.to_unsafe_h if @query_params.respond_to?(:to_unsafe_h)
      @query_params = @query_params.except(
        'controller',
        'action',
        'format',
        'group',
        'max_mb',
        'authenticity_token',
        'token'
      )
    end

    # Returns max bytes for grouping. Uses decimal MB (1,000,000 bytes) not
    # binary MiB (1,048,576 bytes) for user-friendliness.
    def requested_max_bytes
      mb = params[:max_mb].presence
      mb = mb.to_f if mb
      mb = if mb && mb.positive?
             mb
           else
             DEFAULT_MAX_MB
           end
      mb = mb.clamp(MIN_MAX_MB, MAX_MAX_MB)
      (mb * 1_000_000).to_i
    end

    def build_zip_filename(prefix, index, total)
      date = Time.zone.today.strftime('%-m_%-d_%y')
      Zaru.sanitize!("#{prefix}-#{date}-#{index}_of_#{total}.zip").gsub(' ', '_')
    end

    def download_packager(packager:, group_index:, empty_message:, filename_prefix:, entry_selector: nil)
      render json: { error: empty_message }, status: :unprocessable_content and return if @query_params.blank?
      render json: { error: 'Invalid group index.' }, status: :bad_request and return if group_index < 1

      max_bytes = requested_max_bytes
      groups = packager.groups(max_bytes: max_bytes)
      group = groups[group_index - 1]

      render json: { error: 'Group not found.' }, status: :not_found and return if group.blank?

      entry_selector ||= ->(group_entries, packager_instance) {
        # Exclude entries which aren't backed by an actual file (e.g.
        # exclude Images for which the image file has been deleted).
        group_entries.select { |entry| packager_instance.file_available?(entry) }
      }
      entries = entry_selector.call(group, packager)

      render json: { error: 'No files available for this package.' }, status: :unprocessable_content and return if entries.empty?

      filename = build_zip_filename(filename_prefix, group_index, groups.length)
      response.headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
      packager.stream(entries: entries, zip_streamer: method(:zip_tricks_stream), group_index: group_index)
    end

    def preview_packager(packager:, payload_key:, total_key:)
      max_bytes = requested_max_bytes
      preview_data = packager.preview(max_bytes: max_bytes)

      render json: {
        payload_key => preview_data[payload_key],
        groups: preview_data[:groups],
        filter_params: @query_params,
        total_key => preview_data[total_key],
        max_bytes: max_bytes
      }
    end
  end
end

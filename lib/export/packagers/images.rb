# Prepares Images for batch download.
#
# Groups images by size and provides preview data for the UI.
# Uses Export::FileGrouper for size-based grouping.
#
# Authored with assistance from Claude (Anthropic)
module Export
  module Packagers
    class Images
      attr_reader :query_params, :project_id

      def initialize(query_params:, project_id:)
        @query_params = query_params
        @project_id = project_id
        @file_grouper = Export::FileGrouper.new
        @file_available_cache = {}
      end

      def preview(max_bytes:)
        return empty_preview if image_ids.empty?

        images = images_for_query
        groups = group_entries(images, max_bytes)
        group_map = @file_grouper.build_group_map(
          groups: groups,
          id_extractor: ->(image) { image.id }
        )

        {
          images: serialize_images(images, group_map),
          groups: serialize_groups(groups),
          total_images: images.length
        }
      end

      def groups(max_bytes:)
        return [] if image_ids.empty?

        group_entries(images_for_query, max_bytes)
      end

      def file_available?(image)
        @file_available_cache.fetch(image.id) do
          path = image.image_file.path
          @file_available_cache[image.id] = path.present? && File.exist?(path)
        end
      end

      def stream(entries:, zip_streamer:, group_index:)
        Export::ZipStreamer.new.stream(
          entries: entries,
          zip_streamer: zip_streamer,
          file_path: ->(img) { file_path(img) },
          file_name: ->(img) { img.image_file_file_name },
          entry_id: ->(img) { img.id },
          logger_prefix: 'Images packager',
          on_entry: method(:add_manifest_row),
          after_stream: ->(zip, rows, written) {
            write_manifest(zip, rows, written, group_index: group_index)
          }
        )
      end

      private

      def images_for_query
        scope = Queries::Image::Filter.new(query_params).all
        scope = scope.where(project_id: project_id)

        ids = image_ids
        scope.where(id: ids).order(:id)
      end

      def group_entries(images, max_bytes)
        @file_grouper.group(
          items: images.to_a,
          max_bytes: max_bytes,
          size_extractor: ->(image) {
            file_available?(image) ? image.image_file_file_size.to_i : 0
          }
        )
      end

      def serialize_images(images, group_map)
        images.map.with_index(1) do |image, index|
          {
            id: image.id,
            index: index,
            group_index: group_map[image.id],
            size: image.image_file_file_size.to_i,
            name: image.image_file_file_name,
            content_type: image.image_file_content_type,
            width: image.width,
            height: image.height,
            url: image.image_file.url(:original, false),
            thumb_url: image.image_file.url(:thumb, false),
            available: file_available?(image)
          }
        end
      end

      def serialize_groups(groups)
        groups.map.with_index(1) do |group, index|
          available_images = group.select { |image| file_available?(image) }
          {
            index:,
            size: available_images.sum { |image| image.image_file_file_size.to_i },
            image_ids: group.map(&:id),
            available_count: available_images.length
          }
        end
      end

      def file_path(image)
        path = image.image_file.path
        return path if path.present? && File.exist?(path)
        nil
      end

      def add_manifest_row(image, name, rows)
        rows << [
          image.id,
          name,
          image.image_file_file_size.to_i,
          image.width,
          image.height
        ]
      end

      def write_manifest(zip, rows, written, group_index:)
        return if !written || rows.empty?

        zip.write_deflated_file("images-#{group_index}.tsv") do |sink|
          sink.write("image_id\tzip_filename\tfile_size_bytes\twidth\theight\n")
          rows.each do |row|
            sink.write("#{row.join("\t")}\n")
          end
        end
      end

      def image_ids
        Array(query_params[:image_id]).flatten.compact.map(&:to_i).uniq
      end

      def empty_preview
        {
          images: [],
          groups: [],
          total_images: 0
        }
      end
    end
  end
end

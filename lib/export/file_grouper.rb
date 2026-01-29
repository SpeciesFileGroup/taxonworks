# Groups items into size-limited batches for download packaging.
#
# This class provides generic grouping functionality that can be used
# by any file packager (documents, images, etc.).
#
# @example Basic usage
#   grouper = Export::FileGrouper.new
#   groups = grouper.group(
#     items: documents,
#     max_bytes: 50.megabytes,
#     size_extractor: ->(doc) { doc.document_file_file_size.to_i }
#   )
#
# Authored with assistance from Claude (Anthropic)
module Export
  class FileGrouper
    # Groups items into batches that don't exceed max_bytes.
    #
    # Items larger than max_bytes will be placed in their own group.
    # Order of items is preserved.
    #
    # @param items [Array] items to group
    # @param max_bytes [Integer] maximum bytes per group
    # @param size_extractor [Proc] callable that returns size in bytes for an item
    # @return [Array<Array>] array of groups, each group is an array of items
    def group(items:, max_bytes:, size_extractor:)
      groups = []
      current_group = []
      current_size = 0

      items.each do |item|
        size = size_extractor.call(item)

        if current_group.any? && (current_size + size > max_bytes)
          groups << current_group
          current_group = []
          current_size = 0
        end

        current_group << item
        current_size += size
      end

      groups << current_group if current_group.any?
      groups
    end

    # Builds a map from item ID to group index (1-based).
    #
    # @param groups [Array<Array>] grouped items
    # @param id_extractor [Proc] callable that returns ID for an item
    # @return [Hash] mapping of item ID to group index
    def build_group_map(groups:, id_extractor:)
      group_map = {}

      groups.each_with_index do |group, index|
        group.each do |item|
          group_map[id_extractor.call(item)] = index + 1
        end
      end

      group_map
    end
  end
end

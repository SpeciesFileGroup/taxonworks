# Matches an array of identifier strings to CollectionObject records by `identifiers.cached`.
#
# Exact match only, all identifiers are resolved in a single query.
#
# Usage:
#   result = Match::CollectionObject::Identifier.new(
#     identifiers: ['INHS:123', 'INHS:124'],
#     project_id: 1
#   ).call
#
# Returns an Array of Hashes, one per unique input identifier, in order:
#   [
#     {
#       identifier: 'INHS:123',
#       collection_object_id: 456,    # nil unless exactly one CollectionObject matches
#       collection_object_ids: [456],
#       ambiguous: false,
#       matched: true
#     }, ...
#   ]
#
# Claude (Anthropic) provided > 50% of the code for this class.
module Match
  module CollectionObject
    class Identifier

      attr_reader :identifiers, :project_id

      # @param identifiers [Array<String>] identifier strings, compared to `identifiers.cached`
      # @param project_id [Integer]
      def initialize(identifiers:, project_id:)
        @identifiers = identifiers.uniq
        @project_id = project_id
      end

      # @return [Array<Hash>]
      def call
        return [] if identifiers.empty?

        matches = collection_object_ids_by_identifier

        identifiers.map do |identifier|
          ids = matches[identifier] || []

          {
            identifier:,
            collection_object_id: ids.one? ? ids.first : nil,
            collection_object_ids: ids,
            ambiguous: ids.size > 1,
            matched: ids.any?
          }
        end
      end

      private

      # @return [Hash{String => Array<Integer>}]
      def collection_object_ids_by_identifier
        ::Identifier
          .where(project_id:, identifier_object_type: 'CollectionObject', cached: identifiers)
          .distinct
          .pluck(:cached, :identifier_object_id)
          .each_with_object({}) { |(cached, id), h| (h[cached] ||= []).push(id) }
      end
    end
  end
end

# To identify the polymorphic params, include the pertinent model we rereference here
# require_dependency Rails.root.to_s + '/app/models/collecting_event'

module Queries
  module Citation

    class Filter < Query::Filter
      include Queries::Helpers

      include Concerns::Polymorphic
      polymorphic_klass(::Citation)

      PARAMS = [
        *::Citation.related_foreign_keys.map(&:to_sym),
        :citation_id,
        :citation_object_type,
        :citation_object_id,
        :source_id,
        :is_original,
        citation_id: [],
      ].freeze

      # Array, Integer
      attr_accessor :citation_object_type

      attr_accessor :citation_object_id

      attr_accessor :source_id

      # Boolean
      attr_accessor :is_original

      # @params params [Hash]
      #   already Permitted params, or new Hash
      def initialize(query_params)
        super

        @citation_id = params[:citation_id]
        @citation_object_id = params[:citation_object_id]
        @citation_object_type = params[:citation_object_type]
        @is_original = params[:is_original]
        @source_id = params[:source_id]
        set_polymorphic_params(params)
      end

      def citation_object_type
        [@citationcitation_object_type].flatten.compact
      end

      def citation_object_id
        [@citation_object_id].flatten.compact
      end

      def source_id
        [@source_id].flatten.compact
      end

      def citation_id
        [@citation_id].flatten.compact
      end

      #     def merge_clauses
      #       c = []
      #       c = c + source_merge_clauses + source_and_clauses
      #       c.compact!
      #       c
      #     end

      #     def source_merge_clauses
      #       c = []
      #       # Convert base and clauses to merge clauses
      #       source_query.merge_clauses.each do |i|
      #         c.push ::Citation.joins(:source).merge( i )
      #       end
      #       c
      #     end

      #     def source_and_clauses
      #       c = []
      #       # Convert base and clauses to merge clauses
      #       source_query.base_and_clauses.each do |i|
      #         c.push ::Citation.joins(:source).where( i )
      #       end
      #       c
      #     end

      # @return [Arel::Node, nil]
      def matching_citation_object_type
        return nil if citation_object_type.empty?
        table[:citation_object_type].eq(citation_object_type)
      end

      # @return [Arel::Node, nil]
      def matching_citation_object_id
        return nil if citation_object_id.empty?
        table[:citation_object_id].eq(citation_object_id)
      end

      # @return [Arel::Node, nil]
      def source_id_facet
        return nil if source_id.empty?
        table[:source_id].eq_any(source_id)
      end

      # Replace with lib/concerns/user.rb ...
      # Never use Current.user_id here
      # def matching_updated_by_id
      #   return nil if Current.user_id.nil?
      #   user_id == 'true' ? table[:updated_by_id].eq(Current.user_id) : nil
      # end

      def matching_is_original
        is_original.blank? ? nil : table[:is_original].eq(is_original)
      end

      def and_clauses
        [
          matching_citation_object_type,
          matching_citation_object_id,
          source_id_facet,
          matching_is_original
        ]
      end

    end
  end
end

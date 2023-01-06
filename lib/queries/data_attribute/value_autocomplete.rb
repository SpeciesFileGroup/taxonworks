module Queries
  module DataAttribute
    class ValueAutocomplete < Query::Autcomplete

      attr_accessor :predicate_id

      def initialize(string, predicate_id: nil, project_id: nil)
        @predicate_id = predicate_id
        super
      end

      # @return [Scope]
      def where_sql
        with_project_id.and(matching_value.and(matching_controlled_vocabulary_term_id)).to_sql
      end

      # @return [Array]
      #   of matching strings
      def autocomplete
        ::DataAttribute.where(where_sql).order(Arel.sql('LENGTH(value) ASC')).distinct.limit(50).pluck(:value, 'LENGTH(value)').map(&:first)
      end

      # @return [Arel::Nodes::Matches]
      def matching_value 
        return nil if query_string.nil?
        table[:value].matches(start_and_end_wildcard)
      end

      # @return [Arel::Nodes::Matches]
      def matching_controlled_vocabulary_term_id
        return nil if query_string.nil?
        table[:controlled_vocabulary_term_id].eq(predicate_id)
      end

    end
  end
end

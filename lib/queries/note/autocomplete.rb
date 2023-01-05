module Queries
  module Note
    class Autocomplete < Query::Autocomplete

      # @param [Hash] args
      def initialize(string, project_id: nil)
        super
      end

      # @return [Scope]
      def base_query
        ::Note.select('notes.*')
      end

      # @return [ActiveRecord::Relation]
      def autocomplete_exact_note
        a = table[:text].eq(query_string)
        base_query.where(a.to_sql).limit(20)
      end

      # @return [ActiveRecord::Relation]
      def autocomplete_wildcard_end
        a = table[:text].matches(query_string + '%') 
        base_query.where(a.to_sql).limit(8)
      end

      # @return [ActiveRecord::Relation]
      def autocomplete_wildcard_wrapped
        a = table[:text].matches('%' + query_string + '%')
        base_query.where(a.to_sql).limit(5)
      end

      # @return [Arel::Nodes::Matches]
      def autocomplete_ordered_wildcard_pieces
        a = table[:text].matches(wildcard_pieces)
        base_query.where(a.to_sql).limit(10)
      end

      def autocomplete_wildcard_anywhere
        b = fragments
        return nil if b.empty?
        a = table[:text].matches_all(b)
        base_query.where(a.to_sql).limit(20)
      end

      def autocomplete_any_wildcard_anywhere
        b = fragments
        return nil if b.empty?
        a = table[:text].matches_any(b)
        base_query.where(a.to_sql).limit(20)
      end

      # @return [Array]
      def autocomplete
        queries = [
          autocomplete_exact_note,
          autocomplete_wildcard_end,
          autocomplete_wildcard_wrapped,
          autocomplete_ordered_wildcard_pieces,
          autocomplete_wildcard_anywhere,
          autocomplete_any_wildcard_anywhere
        ]

        queries.compact!

        updated_queries = []
        queries.each_with_index do |q ,i|
          a = q.where(with_project_id.to_sql) if project_id 
          a ||= q
          updated_queries[i] = a
        end

        result = []
        updated_queries.each do |q|
          result += q.to_a
          result.uniq!
          break if result.count > 40 
        end
        result[0..40]
      end

      # @return [Arel::Table]
      def table
        ::Note.arel_table
      end
    end
  end
end

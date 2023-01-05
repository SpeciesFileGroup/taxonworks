module Queries
  module Descriptor
    class Autocomplete < Query::Autocomplete
      # @return [String]
      def where_sql
        with_project_id.and(or_clauses).to_sql
      end

      # @return [Arel::Nodes::Grouping]
      def or_clauses
        clauses = [
          named,
          short_named,
          with_id
        ].compact

        a = clauses.shift
        clauses.each do |b|
          a = a.or(b)
        end
        a
      end

      # @return [Arel::Nodes::Matches]
      def short_named
        table[:short_name].matches_any(terms)
      end

      # @return [Scope]
      def all
        ::Descriptor.where(where_sql)
      end

      # @return [Arel::Table]
      def table
        ::Descriptor.arel_table
      end
    end
  end
end

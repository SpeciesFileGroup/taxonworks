module Queries
  module Namespace
    class Autocomplete < Query::Autocomplete

      # @return [String]
      def where_sql
        named.or(or_clauses).to_sql
      end

      def or_clauses
        clauses = [
          short_named,
          verbatim_short_named,
          with_id
        ].compact

        a = clauses.shift
        clauses.each do |b|
          a = a.or(b)
        end
        a
      end

      def short_named
        table[:short_name].matches_any(terms)
      end

      def verbatim_short_named
        table[:verbatim_short_name].matches_any(terms)
      end

      def all
        ::Namespace.where(where_sql)
      end

      def table
        ::Namespace.arel_table
      end
    end
  end
end

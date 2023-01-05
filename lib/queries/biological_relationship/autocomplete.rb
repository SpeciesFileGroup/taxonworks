module Queries
  module BiologicalRelationship

    class Autocomplete < Query::Autocomplete

      # @return [Scope]
      def where_sql
        with_project_id.and(or_clauses).to_sql
      end

      # @return [Scope]
      def or_clauses
        clauses = [
          named,
          with_inverted_name,
          with_id
        ].compact

        a = clauses.shift
        clauses.each do |b|
          a = a.or(b)
        end
        a
      end

      # @return [Scope]
      def all
        # For references, this is equivalent: BiologicalRelationship.eager_load(:taxon_name).where(where_sql)
        ::BiologicalRelationship.where(where_sql).order(name: :asc).limit(50)
      end

      def with_inverted_name
        table[:inverted_name].matches_any(terms)
      end

      # @return [Arel::Table]
      def table
        ::BiologicalRelationship.arel_table
      end

    end
  end
end

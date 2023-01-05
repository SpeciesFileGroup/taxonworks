module Queries
  module Document
    class Autocomplete < Query::Autocomplete

      # @return [String]
      def where_sql
        or_clauses.to_sql
      end

      # @return [Arel::Nodes::Grouping]
      def or_clauses
        clauses = [
          file_name_like,
          with_id
        ].compact

        a = clauses.shift
        clauses.each do |b|
          a = a.or(b)
        end
        a
      end

      # @return [Arel::Nodes::Matches]
      def file_name_like
        table[:document_file_file_name].matches(end_wildcard)
      end

      # @return [Scope]
      def all
        ::Document.where(where_sql).limit(200).order(:id)
      end

      # @return [Arel::Table]
      def table
        ::Document.arel_table
      end

    end
  end
end

module Queries
  module Extract
    class Autocomplete < Queries::Query

      # @params string [String]
      # @params [Hash] args
      def initialize(string, project_id: nil)
        super
      end

      def base_query
        ::Extract.select('extracts.*')
      end

      # @return [Arel::Table]
      def table
        ::Extract.arel_table
      end

      # Find matching names, get their IDs
      # then use ancestor to get target Extracts
      def autocomplete_taxon_name_ancestor_id
        t = ::Queries::TaxonName::Filter.new( name: query_string, project_id: project_id).all

        return [] if t.nil? || t.size > 3

        results = []
        t.each do |i|
          results.push ::Queries::Extract::Filter.new(
            ancestor_id: i.id,
            project_id: project_id
          ).all.limit(10)
        end
        results
      end

      # def autocomplete_otu_determined_as
      #   t = otu_table[:name].matches_any(terms)

      #   ::Extract.
      #     joins(taxon_determinations: [:otu]).
      #     where(t.to_sql).references(:taxon_determinations, :otus).
      #     order('otus.name ASC').limit(10)
      # end

      def autocomplete_in_container_by_identifier_cached_exact
        q = identifier_table[:cached].eq(query_string)
        ::Extract.joins(container: [:identifiers])
          .where(q.to_sql)
      end

      def autocomplete_in_container_by_identifier
        q = identifier_table[:identifier].matches('%' + query_string + '%')
        ::Extract.joins(container: [:identifiers])
          .where(q.to_sql)
      end

      def base_queries
        queries = [
          autocomplete_identifier_cached_exact,
          autocomplete_in_container_by_identifier_cached_exact,
          autocomplete_identifier_identifier_exact,
          autocomplete_exact_id,
          autocomplete_in_container_by_identifier,
          autocomplete_identifier_cached_like,
          # autocomplete_otu_determined_as,
        ] + autocomplete_taxon_name_ancestor_id

        queries.compact!

        return [] if queries.nil?
        updated_queries = []

        queries.each_with_index do |q ,i|
          a = q.where(project_id: project_id) # if project_id
          a ||= q
          updated_queries[i] = a
        end
        updated_queries
      end

      # @return [Array]
      #   TODO: optimize limits
      def autocomplete
        updated_queries = base_queries

        result = []
        updated_queries.each do |q|
          result += q.to_a
          result.uniq!
          break if result.count > 100
        end
        result[0..100]
      end

    end
  end
end

module Queries
  module CollectionObject
    class Autocomplete < Query::Autocomplete

      # @params string [String]
      # @params [Hash] args
      def initialize(string, project_id: nil)
        super
      end

      def base_query
        ::CollectionObject.select('collection_objects.*')
      end

      # @return [Arel::Table]
      def taxon_name_table
        ::TaxonName.arel_table
      end

      # @return [Arel::Table]
      def otu_table
        ::Otu.arel_table
      end

      # @return [Arel::Table]
      def table
        ::CollectionObject.arel_table
      end

      # @return [Arel::Table]
      def containers_table
        ::Container.arel_table
      end

      def autocomplete_taxon_name_determined_as
        t = taxon_name_table[:name].matches_any(terms).or(taxon_name_table[:cached].matches_any(terms) )

        ::CollectionObject.
          includes(:identifiers, taxon_determinations: [otu: :taxon_name]).
          joins(taxon_determinations: [:otu]).
          where(t.to_sql).
          references(:taxon_determinations, :otus, :taxon_names).
          order('otus.name ASC').limit(10)
      end

      def autocomplete_otu_determined_as
        t = otu_table[:name].matches_any(terms)

        ::CollectionObject.
          joins(taxon_determinations: [:otu]).
          where(t.to_sql).references(:taxon_determinations, :otus).
          order('otus.name ASC').limit(10)
      end

      def autocomplete_in_container_by_identifier_cached_exact
        q = identifier_table[:cached].eq(query_string)
        ::CollectionObject.joins(container: [:identifiers])
          .where(q.to_sql)
      end

      def autocomplete_in_container_by_identifier
        q = identifier_table[:identifier].matches('%' + query_string + '%')
        ::CollectionObject.joins(container: [:identifiers])
          .where(q.to_sql)
      end

      def base_queries
        queries = [
          autocomplete_exact_id,
          autocomplete_identifier_cached_exact,
          autocomplete_in_container_by_identifier_cached_exact,
          autocomplete_identifier_identifier_exact,
          autocomplete_in_container_by_identifier,
          autocomplete_taxon_name_determined_as,
          autocomplete_otu_determined_as,
          autocomplete_identifier_cached_like,
        ]

        queries.compact!

        return [] if queries.nil?
        updated_queries = []

        queries.each_with_index do |q ,i|
          a = q.where(project_id: project_id) if project_id
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
          break if result.count > 39
        end
        result[0..39]
      end

    end
  end
end

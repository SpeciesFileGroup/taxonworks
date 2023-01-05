module Queries
  module Extract
    class Autocomplete < Query::Autocomplete

      # @return Array
      #   !! Not an external param
      # TaxonName ids that match the query term
      attr_accessor :taxon_name_ids

      # @params string [String]
      # @params [Hash] args
      def initialize(string, project_id: nil)
        super
      end

      def taxon_name_ids
        @taxon_name_ids ||= ::Queries::TaxonName::Filter.new(
          name: query_string,
          project_id: project_id,
          exact: false,
        ).all.pluck(:id)
        @taxon_name_ids
      end

      def base_query
        ::Extract.select('extracts.*')
      end

      # @return [Arel::Table]
      def table
        ::Extract.arel_table
      end

      # @return [Array]
      #   !! Returns multiple queries !!
      # Find matching names, get their IDs
      # then use ancestor to get target Extracts
      def autocomplete_taxon_name_ancestor_id
        return [] if taxon_name_ids.size > 100

        results = []
        taxon_name_ids.each do |id|
          results.push ::Queries::Extract::Filter.new(
            ancestor_id: id
          ).all.limit(10)
        end
        results
      end

      # Extracts attached to Specimens determined as OTU by otu name taxon name
      def autocomplete_otu_name_determined_as
        t = ::Otu.arel_table[:name].matches_any(terms)
        ::Extract.
          joins(origin_collection_objects: [:otus])
          .where(t.to_sql)
          .order('otus.name ASC')
          .limit(10)
      end

      # Extracts attached to Otus with taxon name
      def autocomplete_otu_taxon_name_id_determined_as
        return nil if taxon_name_ids.empty?
        t = ::Otu.arel_table[:taxon_name_id].eq_any(taxon_name_ids)

        a = ::Extract
          .joins(origin_collection_objects: [otus: [:taxon_name]] ) # Join taxon names to order by name
          .where(t.to_sql) # .references(:taxon_determinations, :otus).
          .order('taxon_names.cached ASC, otus.name ASC')
          .limit(10)
      end

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
          autocomplete_otu_taxon_name_id_determined_as, # here on built here
          autocomplete_otu_name_determined_as,
        ] + autocomplete_taxon_name_ancestor_id

        queries.compact!

        return [] if queries.empty?

        updated_queries = []

        queries.each do |q|
          a = q.where(project_id: project_id) # if project_id
          updated_queries.push a
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

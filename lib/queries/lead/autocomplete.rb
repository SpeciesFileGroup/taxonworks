module Queries
  module Lead
    class Autocomplete < Query::Autocomplete

      def initialize(string, project_id: nil)
        super
      end

      def otu_table
        ::Otu.arel_table
      end

      def taxon_name_table
        ::TaxonName.arel_table
      end

      def autocomplete_text_contains_match
        return nil if query_string.length < 2
        base_query.where('leads.text ilike ?', '%' + query_string + '%').limit(20)
      end

      def autocomplete_description_contains_match
        return nil if query_string.length < 2
        base_query
          .where('parent_id is null')
          .where('leads.description ilike ?', '%' + query_string + '%').limit(20)
      end

      def autocomplete_exact_origin_label
        base_query.where(origin_label: query_string).limit(20)
      end

      def autocomplete_matching_otu_name_start
        return nil if query_string.length < 2
        base_query.joins(:otu)
          .where(otu_table[:name].matches(query_string + '%')).limit(20)
      end

      def autocomplete_matching_taxon_name_start
        return nil if query_string.length < 2
        base_query.joins(:taxon_name)
          .where(taxon_name_table[:cached].matches(query_string + '%')).limit(20)
      end

      def updated_queries
        queries = [
          autocomplete_text_contains_match,
          autocomplete_description_contains_match,
          autocomplete_exact_origin_label,
          autocomplete_matching_otu_name_start,
          autocomplete_matching_taxon_name_start
        ]

        queries.compact!

        return [] if queries.empty?

        updated_queries = []

        queries.each do |q|
          a = q.where(project_id:) if project_id.present?
          updated_queries.push a
        end
        updated_queries
      end

      # @return [Array]
      def autocomplete
        queries = updated_queries

        result = []

        queries.each do |q|
          result += q.to_a
          result.uniq!
          break if result.count > 19
        end
        result[0..19]
      end

    end
  end
end

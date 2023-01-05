module Queries
  module AssertedDistribution 
    class Autocomplete < Queries::Query::Autocomplete
      
      def initialize(string, project_id: nil)
        super
      end

      def otu_table
        ::Otu.arel_table
      end
      
      def taxon_name_table 
        ::TaxonName.arel_table
      end

      def geographic_area_table
        ::GeographicArea.arel_table
      end

      def source_table
        ::Source.arel_table
      end

      def base_query
        ::AssertedDistribution.select('asserted_distributions.*')
      end

      def autocomplete_matching_otu_name
        base_query.joins(:otu).where( otu_table[:name].matches(query_string + '%')   ).limit(20)
      end

      def autocomplete_matching_taxon_name
        base_query.joins(:taxon_name).where( taxon_name_table[:cached].matches(query_string + '%')   ).limit(20)
      end

      def autocomplete_matching_geographic_area
        base_query.joins(:geographic_area).where( geographic_area_table[:name].matches(query_string + '%')   ).limit(50)
      end

      # Dubious use
      def autocomplete_matching_source
        base_query.joins(:sources).where( source_table[:cached].matches('%' + query_string + '%') ).limit(5)
      end

      # @return [Array]
      def autocomplete
        queries = [
          autocomplete_matching_source, 
          autocomplete_matching_otu_name, 
          autocomplete_matching_taxon_name,
          autocomplete_matching_geographic_area,
        ]

        queries = queries.compact

        return [] if queries.empty?
        updated_queries = []

        queries.each_with_index do |q ,i|
          a = q.where(asserted_distributions: {project_id: project_id})
          updated_queries[i] = a
        end

        result = []
        updated_queries.each do |q|
          result += q.to_a
          result.uniq!
          break if result.count > 50
        end
        result[0..50]
      end

    end
  end
end

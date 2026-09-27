module Queries
  module AssertedDistribution
    class Autocomplete < Query::Autocomplete

      # See #autocomplete_biological_association
      LITERAL_RESTRICTION_MAX = 1000

      def initialize(string, project_id: nil)
        super
      end

      def otu_table
        ::Otu.arel_table
      end

      def taxon_name_table
        ::TaxonName.arel_table
      end

      def biological_associations_graph_table
        ::BiologicalAssociationsGraph.arel_table
      end

      def geographic_area_table
        ::GeographicArea.arel_table
      end

      def gazetteer_table
        ::Gazetteer.arel_table
      end

      def source_table
        ::Source.arel_table
      end

      def autocomplete_matching_otu_name
        base_query.with_otus.where( otu_table[:name].matches(query_string + '%')   ).limit(20)
      end

      def autocomplete_matching_taxon_name
        base_query.with_taxon_names.where( taxon_name_table[:cached].matches(query_string + '%')   ).limit(20)
      end

      def autocomplete_biological_association
        # The combinatorics are not great for joining each BA autocomplete
        # option with AD directly, so match on the BA autocomplete results,
        # restricted to BAs that have asserted distributions.
        biological_association_ads = ::AssertedDistribution
          .where(asserted_distribution_object_type: 'BiologicalAssociation')
        if project_id.present?
          biological_association_ads = biological_association_ads.where(project_id:)
        end

        asserted_biological_associations = ::BiologicalAssociation.where(
          id: biological_association_ads.select(:asserted_distribution_object_id)
        )

        # The restriction is re-applied in every query down the
        # BA -> Otu/CO/... -> TaxonName chain (dozens of queries): when there
        # are few ids, passing them literally is much cheaper than
        # re-evaluating the subquery in each; when there are many, the
        # subquery is cheaper.
        ids = biological_association_ads.distinct
          .limit(LITERAL_RESTRICTION_MAX + 1).pluck(:asserted_distribution_object_id)
        if ids.size <= LITERAL_RESTRICTION_MAX
          asserted_biological_associations = ::BiologicalAssociation.where(id: ids)
        end

        biological_association_ids = Queries::BiologicalAssociation::Autocomplete
          .new(query_string, project_id:, restrict_to: asserted_biological_associations)
          .autocomplete.map(&:id)

        biological_association_ads
          .where(asserted_distribution_object_id: biological_association_ids)
      end

      def autocomplete_biological_associations_graph
        # TODO: should search on BAs of graphs as well.
        base_query
          .with_biological_associations_graphs
          .where( biological_associations_graph_table[:name].matches(query_string + '%')   ).limit(20)
      end

      def autocomplete_conveyance_otu_name
        base_query
          .with_otu_conveyances
          .joins('JOIN otus ON otus.id = conveyances.conveyance_object_id')
          .where( otu_table[:name].matches(query_string + '%')   ).limit(20)
      end

      def autocomplete_conveyance_taxon_name
        base_query
          .with_otu_conveyances
          .joins('JOIN otus ON otus.id = conveyances.conveyance_object_id JOIN taxon_names ON taxon_names.id = otus.taxon_name_id')
          .where( taxon_name_table[:cached].matches(query_string + '%')   ).limit(20)
      end

      def autocomplete_depiction_otu_name
        base_query
          .with_otu_depictions
          .joins('JOIN otus ON otus.id = depictions.depiction_object_id')
          .where( otu_table[:name].matches(query_string + '%')   ).limit(20)
      end

      def autocomplete_depiction_taxon_name
        base_query
          .with_otu_depictions
          .joins('JOIN otus ON otus.id = depictions.depiction_object_id JOIN taxon_names ON taxon_names.id = otus.taxon_name_id')
          .where( taxon_name_table[:cached].matches(query_string + '%')   ).limit(20)
      end

      def autocomplete_observation_otu_name
        base_query
          .with_otu_observations
          .joins('JOIN otus ON otus.id = observations.observation_object_id')
          .where( otu_table[:name].matches(query_string + '%')   ).limit(20)
      end

      def autocomplete_observation_taxon_name
        base_query
          .with_otu_observations
          .joins('JOIN otus ON otus.id = observations.observation_object_id JOIN taxon_names ON taxon_names.id = otus.taxon_name_id')
          .where( taxon_name_table[:cached].matches(query_string + '%')   ).limit(20)
      end

      def autocomplete_matching_geographic_area
        base_query.joins("JOIN geographic_areas ON asserted_distributions.asserted_distribution_shape_type = 'GeographicArea' AND asserted_distribution_shape_id = geographic_areas.id").where( geographic_area_table[:name].matches(query_string + '%')   ).limit(50)
      end

      def autocomplete_matching_gazetteer
        base_query.joins("JOIN gazetteers ON asserted_distributions.asserted_distribution_shape_type = 'Gazetteer' AND asserted_distribution_shape_id = gazetteers.id").where( gazetteer_table[:name].matches(query_string + '%')   ).limit(50)
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
          autocomplete_biological_association,
          autocomplete_observation_otu_name,
          autocomplete_observation_taxon_name,
          autocomplete_conveyance_otu_name,
          autocomplete_conveyance_taxon_name,
          autocomplete_depiction_otu_name,
          autocomplete_depiction_taxon_name,
          autocomplete_matching_geographic_area,
          autocomplete_matching_gazetteer,
          autocomplete_biological_associations_graph,
        ]

        queries = queries.compact

        return [] if queries.empty?
        updated_queries = []

        queries.each_with_index do |q ,i|
          a = q.where(asserted_distributions: {project_id:})
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

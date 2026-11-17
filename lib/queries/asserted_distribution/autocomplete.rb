module Queries
  module AssertedDistribution
    class Autocomplete < Query::Autocomplete

      DEFAULT_LIMIT = 50

      def initialize(string, project_id: nil, restrict_to: nil, limit: nil)
        super(string, project_id:, restrict_to:, limit:)
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
        asserted_object_autocomplete(
          object_type: 'BiologicalAssociation',
          object_autocomplete_class: Queries::BiologicalAssociation::Autocomplete,
          object_association: :asserted_distribution_object
        )
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
        # Method names, built in turn, so that later queries (e.g. the
        # biological association one, which runs the BA autocomplete) don't
        # run once the results are filled
        queries = %i[
          autocomplete_matching_source
          autocomplete_matching_otu_name
          autocomplete_matching_taxon_name
          autocomplete_biological_association
          autocomplete_observation_otu_name
          autocomplete_observation_taxon_name
          autocomplete_conveyance_otu_name
          autocomplete_conveyance_taxon_name
          autocomplete_depiction_otu_name
          autocomplete_depiction_taxon_name
          autocomplete_matching_geographic_area
          autocomplete_matching_gazetteer
          autocomplete_biological_associations_graph
        ]

        result = []
        queries.each do |m|
          q = send(m)
          next if q.nil?

          result += apply_restriction(q.where(asserted_distributions: {project_id:})).to_a
          result.uniq!
          break if result.count >= limit
        end
        result.first(limit)
      end

    end
  end
end

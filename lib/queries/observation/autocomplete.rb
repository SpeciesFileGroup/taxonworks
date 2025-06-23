module Queries
  module Observation
    class Autocomplete < Query::Autocomplete

      attr_accessor :polymorphic_types

      def initialize(string, project_id: nil, polymorphic_types: nil)
        super

        @polymorphic_types = polymorphic_types
      end

      def updated_queries
        queries = [
          autocomplete_exact_id,
          autocomplete_identifier_identifier_exact,
          autocomplete_identifier_cached_like,
          autocomplete_observing_otu_by_otu_name,
          autocomplete_observing_otu_by_taxon_name
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
        updated_queries.each do |q|
          result += q.to_a
          result.uniq!
          break if result.count > 19
        end

        result[0..40]
      end

      def autocomplete_observing_otu_by_otu_name
        o = ::Otu.arel_table[:name].matches_any(terms)

        ::Observation
          .joins("JOIN otus ON observations.observation_object_type = 'Otu' AND observations.observation_object_id = otus.id")
          .where(o.to_sql)
          .order('otus.name ASC')
          .limit(20)
      end

      def autocomplete_observing_otu_by_taxon_name
        o = ::TaxonName.arel_table[:cached].matches_any(terms)

        ::Observation
          .joins("JOIN otus ON observations.observation_object_type = 'Otu' AND observations.observation_object_id = otus.id")
          .joins('JOIN taxon_names ON taxon_names.id = otus.taxon_name_id')
          .where(o.to_sql)
          .order('taxon_names.cached ASC')
          .limit(20)
      end

    end
  end
end

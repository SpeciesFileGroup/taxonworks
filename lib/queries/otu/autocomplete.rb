require Rails.root.to_s + '/lib/queries/taxon_name/autocomplete'

module Queries
  module Otu

    class Autocomplete < Query::Autocomplete

      attr_accessor :having_taxon_name_only

      def initialize(string, project_id: nil, having_taxon_name_only: false)
        super(string, project_id: project_id)
        @having_taxon_name_only = having_taxon_name_only&.to_s&.downcase == 'true'
      end

      def base_queries
        queries = []
        queries << autocomplete_exactly_named unless having_taxon_name_only
        queries = [
          autocomplete_exact_id,
          autocomplete_identifier_cached_exact,
          autocomplete_identifier_identifier_exact,
        ]
        queries << autocomplete_named unless having_taxon_name_only
        queries += [
          autocomplete_via_taxon_name_autocomplete,
          autocomplete_identifier_cached_like,
          autocomplete_common_name_exact,
          autocomplete_common_name_like
        ]

        queries.compact!

        return [] if queries.nil?
        updated_queries = []

        queries.each_with_index do |q ,i|
          a = q.where(project_id: project_id) if project_id.present?
          a ||= q
          updated_queries[i] = a
        end

        updated_queries
      end

      # @return [Array]
      def autocomplete
        result = []
        base_queries.each do |q|
          result += q.to_a
          result.uniq!
          break if result.count > 39
        end
        result[0..39]
      end

      # @return [Scope]
      def autocomplete_via_taxon_name_autocomplete
        taxon_names = Queries::TaxonName::Autocomplete.new(query_string, project_id: project_id).autocomplete
        ( having_taxon_name_only ? ::Otu.where(name: nil) : ::Otu)
          .joins(:taxon_name)
          .where(taxon_name: taxon_names)
          .references(:taxon_names)
          .limit(40)
          .order(Arel.sql('char_length(otus.name), char_length(taxon_names.cached), taxon_names.cached ASC'))
      end

    end
  end
end

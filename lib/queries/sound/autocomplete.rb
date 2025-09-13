module Queries
  module Sound
    class Autocomplete < Query::Autocomplete

      # @param [Hash] args
      def initialize(string, project_id: nil)
        super
      end

      def updated_queries
        queries = [
          autocomplete_exact_id,
          autocomplete_identifier_identifier_exact,
          autocomplete_identifier_cached_like,
          autocomplete_name_ilike,
          autocomplete_conveying_otu_by_otu_name,
          autocomplete_conveying_otu_by_taxon_name
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

      def autocomplete_conveying_otu_by_otu_name
        o = ::Otu.arel_table[:name].matches_any(terms)

        ::Sound.
          includes(:otus).
          joins(:otus).
          where(o.to_sql).
          references(:conveyances, :otus).
          order('otus.name ASC').limit(20)
      end

      def autocomplete_conveying_otu_by_taxon_name
        o = ::TaxonName.arel_table[:cached].matches_any(terms)

        ::Sound
          .with_taxon_names
          .where(o.to_sql)
          .order('taxon_names.cached ASC')
          .limit(20)
      end

      def autocomplete_name_ilike
        ::Sound
          .where(named)
          .order(:name)
          .limit(20)
      end

    end
  end
end

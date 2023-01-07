# TaxonNameAutocompleteQuery
module Queries
  module Image 
    class Autocomplete < Queries::Query

      # @param [Hash] args
      def initialize(string, project_id: nil)
        super
      end

      # @return [Arel:Nodes]
      def or_clauses
        clauses = []

        clauses += [
          #  only_ids,
          #  cached,
          #  with_cached_author_year,
        ] unless exact

        clauses.compact!

        a = clauses.shift
        clauses.each do |b|
          a = a.or(b)
        end
        a
      end

      # @return [Arel:Nodes, nil]
      def and_clauses
        clauses = [
          #  valid_state,
          #  is_type,
          #  with_parent_id,
          #  with_nomenclature_group
        ].compact

        return nil if clauses.nil?

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      # @return [Arel:Nodes]
      def or_and
        a = or_clauses
        b = and_clauses

        if a && b
          a.and(b)
        else
          a
        end
      end

      # @return [String]
      def where_sql
        with_project_id.and(or_and).to_sql
      end

      # @return [Array]
      def autocomplete
        queries = [
          autocomplete_exact_id,
          autocomplete_identifier_identifier_exact,
          autocomplete_identifier_cached_like,
          autocomplete_depicting_otu_by_otu_name,
          autocomplete_depicting_otu_by_taxon_name
        ]
        queries.compact!

        updated_queries = []
        queries.each_with_index do |q,i|
          a = q
          a = q.where(project_id: project_id) if project_id.present?
          a = a.where(and_clauses.to_sql) if and_clauses
          updated_queries[i] = a
        end

        result = []
        updated_queries.each do |q|
          result += q.to_a
          result.uniq!
          break if result.count > 19
        end

        result[0..40]
      end

      def autocomplete_depicting_otu_by_otu_name
        o = ::Otu.arel_table[:name].matches_any(terms)

        ::Image.
          includes(:otus).
          joins(:otus).
          where(o.to_sql).
          references(:depictions, :otus).
          order('otus.name ASC').limit(20)
      end

      def autocomplete_depicting_otu_by_taxon_name
        o = ::TaxonName.arel_table[:cached].matches_any(terms)

        ::Image.
          includes(:taxon_names).
          joins(:taxon_names).
          where(o.to_sql).
          references(:depictions, :taxon_names).
          order('taxon_names.cached ASC').limit(20)
      end

    end
  end
end

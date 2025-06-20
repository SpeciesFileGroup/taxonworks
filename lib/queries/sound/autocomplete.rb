module Queries
  module Sound
    class Autocomplete < Query::Autocomplete

      # @param [Hash] args
      def initialize(string, project_id: nil)
        super
      end

      # @return [Arel:Nodes]
      def or_clauses
        return []
        # clauses = []

        #  clauses += [
        #    #  only_ids,
        #  ] unless exact

        #  clauses.compact!

        #  a = clauses.shift
        #  clauses.each do |b|
        #    a = a.or(b)
        #  end
        #  a
      end

    # # @return [Arel:Nodes, nil]
    # def and_clauses
    #   return []
    #   # clauses = [
    #   #   #  valid_state,
    #   #   #  is_type,
    #   #   #  with_parent_id,
    #   #   #  with_nomenclature_group
    #   # ].compact
    #   #
    #   # return nil if clauses.nil?
    #   #
    #   # a = clauses.shift
    #   # clauses.each do |b|
    #   #   a = a.and(b)
    #   # end
    #   # a
    # end

      # @return [Arel:Nodes]
      def or_and
        a = or_clauses
        # b = and_clauses

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

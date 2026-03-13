# Matches an array of name strings to TaxonName records and their associated OTUs.
#
# Usage:
#   result = Match::Otu::TaxonName.new(
#     names: ['Aus bus', 'Cus dus'],
#     project_id: 1,
#     levenshtein_distance: 0,
#     taxon_name_id: nil,
#     resolve_synonyms: false
#   ).call
#
# Returns an Array of Hashes, one per input name:
#   [
#     {
#       scientific_name: 'Aus bus',
#       taxon_name_id: 123,
#       taxon_name: <TaxonName>,
#       otus: [<Otu>, ...],
#       ambiguous: false,
#       matched: true
#     }, ...
#   ]
#
# Claude (Anthropic) provided > 50% of the code for this class.
module Match
  module Otu
    class TaxonName

      MAX_NAMES = 1000

      attr_reader :names, :project_id, :levenshtein_distance, :taxon_name_id, :resolve_synonyms, :try_without_subgenus

      # @param names [Array<String>] array of name strings to match
      # @param project_id [Integer]
      # @param levenshtein_distance [Integer] 0 for exact, 1-8 for fuzzy
      # @param taxon_name_id [Integer, nil] scope matches to descendants of this TaxonName
      # @param resolve_synonyms [Boolean] when true, resolve synonyms to valid names and return their OTUs
      # @param try_without_subgenus [Boolean] when true and cached match fails, try cached_secondary_homonym then cached_primary_homonym
      def initialize(names:, project_id:, levenshtein_distance: 0, taxon_name_id: nil, resolve_synonyms: false, try_without_subgenus: false)
        @names = names.first(MAX_NAMES)
        @project_id = project_id
        @levenshtein_distance = levenshtein_distance.to_i
        @taxon_name_id = taxon_name_id
        @resolve_synonyms = resolve_synonyms
        @try_without_subgenus = try_without_subgenus
      end

      # @return [Array<Hash>]
      def call
        unique_names = names.uniq
        match_cache = {}

        unique_names.each do |name|
          match_cache[name] = match_name(name)
        end

        names.map { |name| match_cache[name].merge(scientific_name: name) }
      end

      private

      # @param name [String]
      # @return [Hash]
      def match_name(name)
        taxon_names = find_taxon_names(name)

        if taxon_names.empty? && try_without_subgenus
          taxon_names = find_taxon_names(name, column: :cached_secondary_homonym)
          if taxon_names.empty?
            taxon_names = find_taxon_names(name, column: :cached_primary_homonym)
          end
        end

        return { taxon_name_id: nil, taxon_name: nil, otus: [], ambiguous: false, matched: false } if taxon_names.empty?

        ranked = rank_taxon_names(taxon_names)
        best = ranked.first

        taxon_name_for_otus = best

        if resolve_synonyms && best.cached_valid_taxon_name_id != best.id
          valid = ::TaxonName.where(project_id: project_id).find_by(id: best.cached_valid_taxon_name_id)
          taxon_name_for_otus = valid if valid
        end

        otus = ::Otu.where(project_id: project_id, taxon_name_id: taxon_name_for_otus.id).to_a

        {
          taxon_name_id: best.id,
          taxon_name: best,
          otus: otus,
          ambiguous: ranked.length > 1,
          matched: true
        }
      end

      # @param name [String]
      # @param column [Symbol] :cached, :cached_secondary_homonym, or :cached_primary_homonym
      # @return [Array<TaxonName>]
      def find_taxon_names(name, column: :cached)
        if levenshtein_distance > 0
          find_taxon_names_fuzzy(name, column:)
        else
          find_taxon_names_exact(name, column:)
        end
      end

      # @param name [String]
      # @param column [Symbol]
      # @return [Array<TaxonName>]
      def find_taxon_names_exact(name, column: :cached)
        scope = base_scope
        scope.where(column => name).to_a
      end

      MATCHABLE_COLUMNS = [:cached, :cached_secondary_homonym, :cached_primary_homonym].freeze

      # @param name [String]
      # @param column [Symbol]
      # @return [Array<TaxonName>]
      def find_taxon_names_fuzzy(name, column: :cached)
        raise ArgumentError, "Invalid column: #{column}" unless MATCHABLE_COLUMNS.include?(column)

        scope = base_scope
        truncated_name = name[0..254]
        distance = [levenshtein_distance, 8].min
        qualified_column = "taxon_names.#{column}"

        scope
          .where(
            "levenshtein(left(#{qualified_column}, 255), ?) <= ?",
            truncated_name,
            distance
          )
          .order(
            Arel.sql(
              ::TaxonName.sanitize_sql_array(
                ["levenshtein(left(#{qualified_column}, 255), ?)", truncated_name]
              )
            )
          )
          .limit(10)
          .to_a
      end

      # Build the base TaxonName scope, optionally constrained to descendants of taxon_name_id.
      # @return [ActiveRecord::Relation]
      def base_scope
        scope = ::TaxonName.where(project_id: project_id)

        if taxon_name_id.present?
          scope = scope
            .joins('JOIN taxon_name_hierarchies ON taxon_names.id = taxon_name_hierarchies.descendant_id')
            .where(taxon_name_hierarchies: { ancestor_id: taxon_name_id })
        end

        scope
      end

      # Rank candidate TaxonNames:
      #   1. Prefer those with OTUs
      #   2. Prefer valid names
      # @param taxon_names [Array<TaxonName>]
      # @return [Array<TaxonName>] sorted best-first
      def rank_taxon_names(taxon_names)
        taxon_name_ids = taxon_names.map(&:id)
        ids_with_otus = ::Otu.where(project_id: project_id, taxon_name_id: taxon_name_ids).distinct.pluck(:taxon_name_id).to_set

        taxon_names.sort_by do |tn|
          [
            ids_with_otus.include?(tn.id) ? 0 : 1,
            tn.cached_valid_taxon_name_id == tn.id ? 0 : 1
          ]
        end
      end
    end
  end
end

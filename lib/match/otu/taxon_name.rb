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
# When `candidates:` is provided each Hash also carries `candidates: [<TaxonName>, ...]`,
# the ranked match set (best first) rather than only the single best match.
#
# All options added after the initial implementation are opt-in: with their defaults the
# returned Hashes and the matches themselves are identical to the original behaviour.
#
# Claude (Anthropic) provided > 50% of the code for this class.
module Match
  module Otu
    class TaxonName

      MAX_NAMES = 3000

      # Columns that may be interpolated into the raw SQL below.
      MATCHABLE_COLUMNS = [
        :cached, :cached_original_combination, :cached_secondary_homonym, :cached_primary_homonym
      ].freeze

      # Candidates gathered per name before ranking.
      FUZZY_LIMIT = 10

      attr_reader :names, :project_id, :levenshtein_distance, :taxon_name_id, :taxon_name_query,
        :resolve_synonyms, :try_without_subgenus, :candidates, :match_original_combination,
        :use_author_year, :trigram_prefilter

      # @param names [Array<String>] array of name strings to match
      # @param project_id [Integer]
      # @param levenshtein_distance [Integer] 0 for exact, 1-8 for fuzzy
      # @param taxon_name_id [Integer, nil] scope matches to descendants of this TaxonName
      # @param taxon_name_query [Hash, nil] scope matches to the result of a
      #   Queries::TaxonName::Filter. Takes precedence over taxon_name_id.
      # @param resolve_synonyms [Boolean] when true, resolve synonyms to valid names and return their OTUs
      # @param try_without_subgenus [Boolean] when true and cached match fails, try cached_secondary_homonym then cached_primary_homonym
      # @param candidates [Integer, nil] when set, include the ranked match set, capped at this many
      # @param match_original_combination [Boolean] when true, match cached_original_combination alongside cached
      # @param use_author_year [Boolean] when true, strip a parseable author/year from the name before
      #   matching and use it to differentiate when more than one candidate matches
      # @param trigram_prefilter [Boolean] when true, narrow fuzzy candidates with the pg_trgm
      #   similarity operator before computing levenshtein distance
      def initialize(names:, project_id:, levenshtein_distance: 0, taxon_name_id: nil,
                     taxon_name_query: nil, resolve_synonyms: false, try_without_subgenus: false,
                     candidates: nil, match_original_combination: false, use_author_year: false,
                     trigram_prefilter: false)
        @names = names.first(MAX_NAMES)
        @project_id = project_id
        @levenshtein_distance = levenshtein_distance.to_i.clamp(0, 8)
        @taxon_name_id = taxon_name_id
        @taxon_name_query = taxon_name_query
        @resolve_synonyms = resolve_synonyms
        @try_without_subgenus = try_without_subgenus
        @candidates = candidates&.to_i
        @match_original_combination = match_original_combination
        @use_author_year = use_author_year
        @trigram_prefilter = trigram_prefilter
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
        parsed = parsed_author_year(name)
        search_string = parsed ? parsed[:name] : name

        taxon_names = find_taxon_names(search_string)

        if taxon_names.empty? && try_without_subgenus
          taxon_names = find_taxon_names(search_string, columns: [:cached_secondary_homonym])
          if taxon_names.empty?
            taxon_names = find_taxon_names(search_string, columns: [:cached_primary_homonym])
          end
        end

        # An unambiguous match needs no differentiating.
        if parsed && taxon_names.size > 1
          taxon_names = differentiate_by_author_year(taxon_names, parsed)
        end

        return no_match if taxon_names.empty?

        ranked = rank_taxon_names(taxon_names)
        matched = ranked.first
        resolved = matched

        if resolve_synonyms && matched.cached_valid_taxon_name_id != matched.id
          valid = ::TaxonName.where(project_id: project_id).find_by(id: matched.cached_valid_taxon_name_id)
          resolved = valid if valid
        end

        otus = ::Otu.where(project_id: project_id, taxon_name_id: resolved.id).to_a

        result = {
          taxon_name_id: resolved.id,
          taxon_name: resolved,
          otus: otus,
          ambiguous: genuinely_ambiguous?(ranked),
          matched: true
        }

        result[:candidates] = ranked.first(candidates) if candidates
        result
      end

      # @return [Hash]
      def no_match
        result = { taxon_name_id: nil, taxon_name: nil, otus: [], ambiguous: false, matched: false }
        result[:candidates] = [] if candidates
        result
      end

      # Multiple candidate rows aren't ambiguous if they all resolve to the
      # same valid taxon (e.g. a Combination alongside its own Protonym) —
      # ranking always picks correctly there. Only flag it when candidates
      # point to genuinely different valid taxa (e.g. true homonyms).
      # @param ranked [Array<TaxonName>]
      # @return [Boolean]
      def genuinely_ambiguous?(ranked)
        ranked.map(&:cached_valid_taxon_name_id).uniq.length > 1
      end

      # @return [Array<Symbol>]
      def default_columns
        match_original_combination ? [:cached, :cached_original_combination] : [:cached]
      end

      # @param name [String]
      # @param columns [Array<Symbol>] subset of MATCHABLE_COLUMNS
      # @return [Array<TaxonName>]
      def find_taxon_names(name, columns: default_columns)
        columns.each do |column|
          raise ArgumentError, "Invalid column: #{column}" unless MATCHABLE_COLUMNS.include?(column)
        end

        if levenshtein_distance > 0
          find_taxon_names_fuzzy(name, columns:)
        else
          find_taxon_names_exact(name, columns:)
        end
      end

      # @param name [String]
      # @param columns [Array<Symbol>]
      # @return [Array<TaxonName>]
      def find_taxon_names_exact(name, columns:)
        clause = columns.collect { |column| "taxon_names.#{column} = ?" }.join(' OR ')
        base_scope.where(clause, *Array.new(columns.size, name)).to_a
      end

      # @param name [String]
      # @param columns [Array<Symbol>]
      # @return [Array<TaxonName>]
      def find_taxon_names_fuzzy(name, columns:)
        truncated_name = name[0..254]
        scope = base_scope

        # levenshtein() can not be indexed, so without this every name in the batch scans
        # taxon_names. The pg_trgm operator uses the GIN trigram indexes on these columns to
        # narrow the set first. Very short strings can fall below the similarity threshold, so
        # this trades some fuzzy recall for a query that is viable at page scale.
        if trigram_prefilter
          similarity = columns.collect { |column| "taxon_names.#{column} % ?" }.join(' OR ')
          scope = scope.where(similarity, *Array.new(columns.size, truncated_name))
        end

        distance = distance_sql(columns, truncated_name)

        scope
          .where("#{distance} <= ?", levenshtein_distance)
          .order(Arel.sql(distance))
          .limit(FUZZY_LIMIT)
          .to_a
      end

      # @param columns [Array<Symbol>]
      # @param name [String]
      # @return [String] sanitized SQL for the distance to the nearest of `columns`
      def distance_sql(columns, name)
        parts = columns.collect do |column|
          ::TaxonName.sanitize_sql_array(
            ["levenshtein(left(taxon_names.#{column}, 255), ?)", name]
          )
        end

        parts.one? ? parts.first : "LEAST(#{parts.join(', ')})"
      end

      # Build the base TaxonName scope, optionally constrained to a TaxonName query result or to
      # descendants of taxon_name_id.
      # @return [ActiveRecord::Relation]
      def base_scope
        scope = ::TaxonName.where(project_id: project_id)

        if taxon_name_query.present?
          scope = scope.where(id: taxon_name_query_scope)
        elsif taxon_name_id.present?
          scope = scope
            .joins('JOIN taxon_name_hierarchies ON taxon_names.id = taxon_name_hierarchies.descendant_id')
            .where(taxon_name_hierarchies: { ancestor_id: taxon_name_id })
        end

        scope
      end

      # Memoized — the same subquery serves every name in the batch.
      # @return [ActiveRecord::Relation]
      def taxon_name_query_scope
        @taxon_name_query_scope ||= ::Queries::TaxonName::Filter
          .new(taxon_name_query.merge(project_id: project_id))
          .all
          .unscope(:order)
          .select(:id)
      end

      # Parse an author/year off the name, when there is one to parse.
      # Memoized per unique string — the parser is comparatively expensive and names repeat.
      # @param name [String]
      # @return [Hash, nil]
      #   `{name: <name without the author/year>, author_year: <'Smith, 1920'>}`, or nil when
      #   the string is unparseable or carries no author/year.
      def parsed_author_year(name)
        return nil unless use_author_year

        @parsed_author_years ||= {}
        return @parsed_author_years[name] if @parsed_author_years.key?(name)

        @parsed_author_years[name] = begin
          result = ::Vendor::Biodiversity::Result.new(query_string: name, project_id: project_id)

          if result.parseable && result.is_authored?
            { name: result.name_without_author_year, author_year: result.author_year }
          else
            nil
          end
        rescue StandardError
          # Arbitrary curator-supplied strings reach the parser; an unparseable one simply
          # matches with its author/year left in place.
          nil
        end
      end

      # Mirrors Vendor::Biodiversity::Result#scope_to_author_year: when the author/year matches
      # candidates, use only those; when it matches none, ignore it rather than discarding every
      # candidate.
      # @param taxon_names [Array<TaxonName>]
      # @param parsed [Hash]
      # @return [Array<TaxonName>]
      def differentiate_by_author_year(taxon_names, parsed)
        author_year = parsed[:author_year]
        return taxon_names if author_year.blank?

        alternate = author_year.gsub(' & ', ' and ')
        matching = taxon_names.select { |tn| [author_year, alternate].include?(tn.cached_author_year) }

        matching.presence || taxon_names
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

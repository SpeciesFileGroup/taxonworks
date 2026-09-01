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
      include NameBatchMatcher

      # Columns that may be interpolated into the raw SQL below.
      MATCHABLE_COLUMNS = [:cached, :cached_original_combination].freeze

      # Candidates gathered per name before ranking.
      CANDIDATES_LIMIT = 10

      # Genus, species, and subspecies ranks for those codes that have a
      # subgenus rank.
      GENUS_RANK_CLASSES = CODES_WITH_SUBGENUS.map { |code|
        Ranks.lookup(code, :genus)
      }.freeze
      SPECIES_RANK_CLASSES = CODES_WITH_SUBGENUS.map { |code|
        Ranks.lookup(code, :species)
      }.freeze
      SUBSPECIES_RANK_CLASSES = CODES_WITH_SUBGENUS.map { |code|
        Ranks.lookup(code, :subspecies)
      }.freeze

      # Deeper ICN-only infraspecific ranks — ICZN/ICNP don't have these.
      VARIETY_RANK_CLASSES = [Ranks.lookup(:icn, :variety)].freeze
      SUBVARIETY_RANK_CLASSES = [Ranks.lookup(:icn, :subvariety)].freeze
      FORM_RANK_CLASSES = [Ranks.lookup(:icn, :form)].freeze
      SUBFORM_RANK_CLASSES = [Ranks.lookup(:icn, :subform)].freeze

      SPECIES_GROUP_MARKERS = [
        ['subsp', SUBSPECIES_RANK_CLASSES],
        ['subvar', SUBVARIETY_RANK_CLASSES],
        ['var', VARIETY_RANK_CLASSES],
        ['subf', SUBFORM_RANK_CLASSES],
        ['f', FORM_RANK_CLASSES]
      ].freeze
      SPECIES_GROUP_MARKER_RANKS = SPECIES_GROUP_MARKERS.to_h.freeze

      SPECIES_GROUP_MARKER_ALTERNATION = SPECIES_GROUP_MARKERS.map(&:first).join('|')
      # Scans for markers, requiring something after them (the epithet); `\b`
      # keeps `var`/`f` from matching inside `subvar.`/`subf.`.
      SPECIES_GROUP_MARKER_SCAN_PATTERN = /\b(#{SPECIES_GROUP_MARKER_ALTERNATION})\.\s+\S/i
      SPECIES_GROUP_SPLIT_PATTERN = /\s*\b(?:#{SPECIES_GROUP_MARKER_ALTERNATION})\.\s+/i

      GENUS_GROUP_MARKER_PATTERN = /\s*\b(?:subg|sgen|subsect|sect|subser|ser)\.\s+\S+/i

      NON_GENDER_AGREEING_PART_OF_SPEECH_TYPES = [
        'TaxonNameClassification::Latinized::PartOfSpeech::NounInApposition',
        'TaxonNameClassification::Latinized::PartOfSpeech::NounInGenitiveCase'
      ].freeze

      ORIGINAL_GENUS_RELATIONSHIP_TYPE =
        'TaxonNameRelationship::OriginalCombination::OriginalGenus'.freeze

      attr_reader :names, :project_id, :levenshtein_distance, :taxon_name_id,
        :taxon_name_query, :resolve_synonyms, :try_without_subgenus,
        :candidates, :match_original_combination, :use_author_year,
        :trigram_prefilter

      # @param names [Array<String>] array of name strings to match
      # @param project_id [Integer]
      # @param levenshtein_distance [Integer] 0 for exact, 1-8 for fuzzy
      # @param taxon_name_id [Integer, nil] scope matches to descendants of this
      #   TaxonName
      # @param taxon_name_query [Hash, nil] scope matches to the result of a
      #   Queries::TaxonName::Filter. Takes precedence over taxon_name_id.
      # @param resolve_synonyms [Boolean] when true, resolve synonyms to valid
      #   names and return their OTUs
      # @param try_without_subgenus [Boolean] when true and the plain match
      #   fails, retry against other spellings within the same species
      #   description complex:
      #     * subgenus (and other genus-group ranks) ignored,
      #     * species-group epithets gender-tolerant,
      #     * genus matched as either current or original.
      # @param candidates [Integer, nil] when set, include the ranked match set,
      #   capped at this many
      # @param match_original_combination [Boolean] when true, match
      #   cached_original_combination alongside cached
      # @param use_author_year [Boolean] when true, strip a parseable
      #   author/year from the name before matching and use it to differentiate
      #   when more than one candidate matches
      # @param trigram_prefilter [Boolean] when true, narrow fuzzy candidates
      #   with the pg_trgm similarity operator before computing levenshtein
      #   distance
      def initialize(
        names:, project_id:, levenshtein_distance: 0, taxon_name_id: nil,
        taxon_name_query: nil, resolve_synonyms: false,
        try_without_subgenus: false, candidates: nil,
        match_original_combination: false, use_author_year: false,
        trigram_prefilter: false
      )
        @names = names.first(NameBatchMatcher::MAX_NAMES)
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

      private

      # @param name [String]
      # @return [Hash]
      def match_name(name)
        parsed = parsed_author_year(name)
        search_string = parsed ? parsed[:name] : name

        taxon_names = find_taxon_names(search_string)

        if taxon_names.empty? && try_without_subgenus
          taxon_names = find_taxon_names_ignoring_subgenus(search_string)
        end

        if parsed && taxon_names.size > 1
          taxon_names = differentiate_by_author_year(taxon_names, parsed)
        end

        return no_match if taxon_names.empty?

        ranked = rank_taxon_names(taxon_names)
        matched = ranked.first
        resolved = matched

        if resolve_synonyms && matched.cached_valid_taxon_name_id != matched.id
          valid = ::TaxonName
            .where(project_id: project_id)
            .find_by(id: matched.cached_valid_taxon_name_id)
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
        result = {
          taxon_name_id: nil,
          taxon_name: nil,
          otus: [],
          ambiguous: false,
          matched: false
        }
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
      def default_column
        if match_original_combination
          [:cached, :cached_original_combination]
        else
          [:cached]
        end
      end

      # Genus-group content (subgenus, section, series...) is always stripped
      # first — it's never read.
      # What's left is either explicitly marked with species-group rank
      # abbreviations (subsp./var./f./...), in which case every rank present is
      # matched gender-tolerantly, anchored in sequence; or it's bare, in which
      # case word count (plus capitalization, to spot a bare subgenus) decides
      # the shape.
      # The genus itself may match either the current classification or the
      # genus a name was originally described in.
      # @param search_string [String]
      # @return [Array<TaxonName>]
      def find_taxon_names_ignoring_subgenus(search_string)
        # Remove all name words marked by a genus group marker, like 'subg. Bus'
        stripped = search_string.gsub(GENUS_GROUP_MARKER_PATTERN, ' ').squish
        # markers are rank indicator words, like ['subsp', 'var'] e.g.
        markers = stripped.scan(SPECIES_GROUP_MARKER_SCAN_PATTERN).flatten.map(&:downcase)

        # If the search string uses any marker words then we assume it uses
        # them consistently:
        return find_via_species_group_markers(stripped:, markers:) if markers.any?

        # If there are no marker words then we attempt to match by position:
        words = stripped.split(' ')

        case words.length
        when 2 # 'Aus bus'
          find_via_species_group_chain(
            genus_name: words.first,
            anchors: [],
            terminal_epithet: words.last,
            terminal_rank_classes: SPECIES_RANK_CLASSES
          )
        when 3
          if words[1].start_with?('(') || words[1] =~ /\A[[:upper:]]/
            # 'Aus (Bus) cus' or 'Aus Bus cus'
            find_via_species_group_chain(
              genus_name: words.first,
              anchors: [],
              terminal_epithet: words.last,
              terminal_rank_classes: SPECIES_RANK_CLASSES
            )
          else
            # Aus bus cus
            find_via_species_group_chain(
              genus_name: words.first,
              anchors: [[words[1], SPECIES_RANK_CLASSES]],
              terminal_epithet: words.last,
              terminal_rank_classes: SUBSPECIES_RANK_CLASSES
            )
          end
        when 4 # 'Aus (Bus) cus dus'
          find_via_species_group_chain(
            genus_name: words.first,
            anchors: [[words[-2], SPECIES_RANK_CLASSES]],
            terminal_epithet: words.last,
            terminal_rank_classes: SUBSPECIES_RANK_CLASSES
          )
        else # we could only guess: don't guess
          []
        end
      end

      # @param stripped [String] the search string with genus-group markers
      #   already removed
      # @param markers [Array<String>] the species-group markers found, in
      #   appearance order (e.g. ['subsp', 'var'])
      # @return [Array<TaxonName>]
      def find_via_species_group_markers(stripped:, markers:)
        segments = stripped.split(SPECIES_GROUP_SPLIT_PATTERN)
        return [] unless segments.size == markers.size + 1
        return [] if segments[1..].any? { |segment| segment.include?(' ') }

        first_words = segments.first.split(' ') # 'Aus bus', genus + species
        return [] if first_words.size < 2

        anchors = [[first_words.last, SPECIES_RANK_CLASSES]]
        anchors += segments[1..-2].each_with_index.map do |epithet, i|
          [epithet, SPECIES_GROUP_MARKER_RANKS.fetch(markers[i])]
        end

        find_via_species_group_chain(
          genus_name: first_words.first,
          anchors:,
          terminal_epithet: segments.last,
          terminal_rank_classes: SPECIES_GROUP_MARKER_RANKS.fetch(markers.last)
        )
      end

      # @param genus_name [String] exact genus name — current or original
      # @param anchors [Array<Array(String, Array<String>)>]
      #   ordered [epithet, rank_classes] pairs, shallowest first — each an
      #   ancestor the terminal must descend through, matched the same
      #   gender-tolerant way as the terminal (see #epithet_match_sql)
      # @param terminal_epithet [String] the terminal word as typed; matched
      #   against its predicted gender forms, not the raw string
      # @param terminal_rank_classes [Array<String>]
      # @return [Array<TaxonName>]
      def find_via_species_group_chain(
        genus_name:, anchors:, terminal_epithet:, terminal_rank_classes:
      )
        epithet_sql, epithet_binds =
          epithet_match_sql('taxon_names', terminal_epithet)

        scope = base_scope
          .where(rank_class: terminal_rank_classes)
          .where(epithet_sql, *epithet_binds)

        if anchors.empty?
          genus_sql, genus_binds = genus_match_sql('taxon_names.id', genus_name)
          scope.where(genus_sql, *genus_binds).to_a
        else
          sql, binds = anchor_chain_sql(genus_name, anchors)
          scope.where("taxon_names.parent_id IN (#{sql})", *binds).to_a
        end
      end

      # Builds a nested subquery (and matching binds, in the same left-to-right
      # order they appear in the SQL) selecting the id of the deepest anchor: a
      # chain through `anchors` (shallowest first, each matched the same
      # gender-tolerant way as the terminal), ultimately rooted so `genus_name`
      # is some match — current or original — for the shallowest one.
      # @param genus_name [String]
      # @param anchors [Array<Array(String, Array<String>)>]
      # @return [Array(String, Array)]
      def anchor_chain_sql(genus_name, anchors)
        sql = nil
        binds = []

        anchors.each_with_index do |(epithet, rank_classes), i|
          alias_name = "anchor_#{i}"
          epithet_sql, epithet_binds = epithet_match_sql(alias_name, epithet)

          if i.zero?
            parent_sql, parent_binds = genus_match_sql("#{alias_name}.id", genus_name)
          else
            parent_sql = "#{alias_name}.parent_id IN (#{sql})"
            parent_binds = binds # the previous iteration's fully-nested binds
          end

          sql = <<~SQL.squish
            SELECT #{alias_name}.id FROM taxon_names #{alias_name}
            WHERE #{alias_name}.project_id = taxon_names.project_id
              AND #{alias_name}.rank_class IN (?)
              AND #{epithet_sql}
              AND #{parent_sql}
          SQL

          binds = [rank_classes] + epithet_binds + parent_binds
        end

        [sql, binds]
      end

      # A candidate matches either by being an exact hit, or by matching one of
      # the predicted gender forms, PROVIDED it isn't classified as a noun
      # (in apposition, or genitive case) — those never take a different
      # gender-agreeing spelling regardless of what the genus's gender is.
      # @param table_alias [String]
      # @param epithet [String] the raw epithet as typed
      # @return [Array(String, Array)] the SQL fragment and its binds, in order
      def epithet_match_sql(table_alias, epithet)
        downcased = epithet.downcase
        forms = Utilities::Nomenclature.predict_three_forms(downcased).values.uniq

        sql = <<~SQL.squish
          (
            #{table_alias}.name = ?
            OR (
              #{table_alias}.name IN (?)
              AND NOT EXISTS (
                SELECT 1 FROM taxon_name_classifications tnc
                WHERE tnc.taxon_name_id = #{table_alias}.id
                  AND tnc.type IN (?)
              )
            )
          )
        SQL

        [sql, [downcased, forms, NON_GENDER_AGREEING_PART_OF_SPEECH_TYPES]]
      end

      # True when `genus_name` is a match for the row identified by
      # `descendant_id_sql`, either as its current classification — some
      # ancestor, any number of generations, so any intervening
      # subgenus/section/etc. is skipped over — or as the genus it was
      # originally described in (before any reclassification), via a
      # TaxonNameRelationship::OriginalCombination::OriginalGenus record.
      # @param descendant_id_sql [String] a SQL expression for the descendant's
      #   id, e.g. 'anchor_0.id'
      # @param genus_name [String]
      # @return [Array(String, Array)] the SQL fragment and its binds, in order
      def genus_match_sql(descendant_id_sql, genus_name)
        ancestor_sql = <<~SQL.squish
          EXISTS (
            SELECT 1 FROM taxon_name_hierarchies tnh
            JOIN taxon_names genus_tn ON genus_tn.id = tnh.ancestor_id
            WHERE tnh.descendant_id = #{descendant_id_sql}
              AND tnh.generations > 0
              AND genus_tn.project_id = taxon_names.project_id
              AND genus_tn.name = ?
              AND genus_tn.rank_class IN (?)
          )
        SQL
        ancestor_binds = [genus_name, GENUS_RANK_CLASSES]

        original_genus_sql = <<~SQL.squish
          EXISTS (
            SELECT 1 FROM taxon_name_relationships tnr
            JOIN taxon_names original_genus_tn ON original_genus_tn.id = tnr.subject_taxon_name_id
            WHERE tnr.object_taxon_name_id = #{descendant_id_sql}
              AND tnr.type = ?
              AND original_genus_tn.project_id = taxon_names.project_id
              AND original_genus_tn.name = ?
              AND original_genus_tn.rank_class IN (?)
        SQL
        original_genus_binds = [
          ORIGINAL_GENUS_RELATIONSHIP_TYPE, genus_name, GENUS_RANK_CLASSES
        ]

        [
          "(#{ancestor_sql} OR #{original_genus_sql})",
          ancestor_binds + original_genus_binds
        ]
      end

      # @param name [String]
      # @param columns [Array<Symbol>] subset of MATCHABLE_COLUMNS
      # @return [Array<TaxonName>]
      def find_taxon_names(name, columns: default_column)
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
          .limit(CANDIDATES_LIMIT)
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

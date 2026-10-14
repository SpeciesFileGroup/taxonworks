module Vendor
  module Colrapi

    # Translates between how the Catalogue of Life writes a name and how
    # TaxonWorks stores its names.
    #
    # CoL's formatting depends on the source dataset (sector) a name came from,
    # and isn't always consistent within one source. What has been seen so far
    # (live CoL, 3LR, 2026-09):
    #   * subgenus: "Genus (Subgenus)" for zoological names, in search
    #     results and classifications, but "Genus subgen. Subgenus" for
    #     botanical ones (all 183 botanical subgenera in the backbone, every
    #     one a synonym, 2026-10). TaxonWorks stores the bare epithet in #name
    #     and "Genus (Subgenus)" in #cached (ICZN and ICN alike). The
    #     parentheses are ICZN's rule (Art. 6.1). The ICN writes a subgenus
    #     "Genus subg. Epithet" (Art. 21.1) and only recommends parentheses
    #     (Rec. 21A.1) for showing it inside a species name.
    #   * species group: some sources include the subgenus ("Aedes (Stegomyia)
    #     aegypti", mosquitoes), some omit it ("Bombus terrestris", bees), and
    #     one source can do both (Carabus: "Carabus (Megodontus) violaceus" but
    #     "Carabus violaceus violaceus"). TaxonWorks #cached includes the
    #     subgenus whenever the name is placed under one.
    #   * synonyms can differ from their accepted name within one source: WAD
    #     gives accepted "Aphrophora (Aphrophora) stictica" with the subgenus,
    #     its synonym "Aphrophora binomoriensis" without it (2026-10).
    #   * a name's original combination can be listed as a synonym of the
    #     same species, differing only by subgenus ("Aphrophora ambigua" ->
    #     "Aphrophora (Aphrophora) ambigua", WAD). So a CoL synonym whose
    #     accepted name is the same name once the subgenus is ignored (both
    #     have the same comparison key, see below) doesn't mean a TaxonWorks
    #     name matching it is outdated.
    #   * searching: a query including the subgenus doesn't return a name CoL
    #     gives without it ("Aphrophora (Aphrophora) binomoriensis" misses
    #     "Aphrophora binomoriensis"), while a query without it still returns
    #     names CoL gives with it ("Aedes aegypti" finds "Aedes (Stegomyia)
    #     aegypti", "Aphrophora ambigua" finds both forms) - see .search_term.
    #     !! The single query in .search_term depends on that second half: it's
    #     observed CoL search behavior (2026-10), not documented. If CoL ever
    #     stops matching that way, names CoL gives with a subgenus silently go
    #     missing (e.g. Outdated Names reports them :undeterminable) and specs,
    #     which stub CoL, won't notice - a second query including the subgenus
    #     would then be needed.
    #   * ICN infraspecific names include connecting terms ("Olea europaea
    #     subsp. africana"), same as TaxonWorks #cached.
    #   * [sic] is TaxonWorks-only (#cached), CoL doesn't send it.
    #
    # Names are compared by a "key" computed the same way from both sides:
    #  * col_name_key - for a name as CoL gives it
    #  * taxonworks_name_keys - for each form of a TaxonName (see .forms)
    #  * name_key - for a naked/unassociated name
    # The key is never displayed or used to create anything, though it is what
    # CoL is searched with (.search_term).
    #
    # Asks of CoL - things CoL's API should handle rather than TaxonWorks
    # working around them. What we do in the meantime:
    #   * search should find a name with or without its subgenus, both ways.
    #     A query with the subgenus misses names CoL gives without one, so we
    #     search without it (.search_term).
    #   * a name should come formatted the same way whatever its source
    #     (subgenus included or not, a synonym like its accepted name). We
    #     compare keys that ignore the subgenus.
    #   * search should accept "Genus (Subgenus)" for a botanical subgenus,
    #     not only "Genus subgen. Subgenus". Not worked around, see
    #     Vendor::Colrapi.search.
    #   * search should find a fossil name without its dagger (†). Not worked
    #     around.
    #   * the formats of ICN section, subsection, series, subseries (and ICZN
    #     supersubgenus/infragenus) names should be documented - no CoL
    #     examples were found. Not handled: TaxonWorks #cached for these is
    #     just the genus, so #name would need to be compared.
    #   * author/year formats should be consistent across sources (they
    #     likely vary as names do). Not handled.
    #
    module NameTranslation

      # The string to search CoL with for a name (TaxonWorks #cached or free
      # text) so that every form CoL may give it in comes back.
      #
      # !! One query covers both forms only because CoL's search returns names
      # with a subgenus for a query without one - observed, not documented;
      # see the search note above before relying on this elsewhere.
      #
      # @param name [String, nil]
      # @return [String, nil]
      def self.search_term(name)
        comparable(name)
      end

      # A whole subgenus name: "Genus (Subgenus)" (CoL zoological, and
      # TaxonWorks #cached for any code) or "Genus subgen. Subgenus" (CoL
      # botanical). The epithet is in group 1 or 2.
      SUBGENUS_NAME = /\A\S+ (?:\(([^)]+)\)|subgen\. (\S+))\z/

      # TaxonWorks Protonym#name for a subgenus: just the epithet.
      #
      # @param col_name [String, nil] a subgenus name (see SUBGENUS_NAME) or
      #   a bare epithet, which is returned as is
      # @return [String, nil]
      def self.subgenus_epithet(col_name)
        return nil if col_name.nil?

        match = col_name.strip.match(SUBGENUS_NAME)
        match ? (match[1] || match[2]) : col_name
      end

      # CoL classification entries give species-group names in full ("Olea
      # europaea", "Carabus (Megodontus) violaceus", "Olea europaea subsp.
      # cuspidata"), TaxonWorks Protonym#name takes just the last epithet.
      # Names that are already an epithet or uninomial are returned as is.
      #
      # @param col_name [String, nil]
      # @param rank [String, nil] CoL rank name, e.g. 'species'
      # @return [String, nil] the TaxonWorks Protonym#name for col_name
      def self.protonym_name(col_name, rank)
        return nil if col_name.nil?
        return subgenus_epithet(col_name) if rank == 'subgenus'

        col_name.split(' ').last
      end

      # @param col_name [String, nil] a name as CoL gives it
      # @param rank [String, nil] CoL rank name, e.g. 'subgenus'
      # @return [String, nil] the comparison key for col_name
      def self.col_name_key(col_name, rank)
        return nil if col_name.nil?
        if rank == 'subgenus'
          return subgenus_epithet(
            ::Utilities::Nomenclature.unmisspell_name(col_name)
          )
        end

        comparable(col_name)
      end

      # The comparison key for a name given as text on the TaxonWorks side -
      # use only when there's no TaxonName (else see .taxonworks_name_keys).
      #
      # @param name [String, nil]
      # @return [String, nil]
      def self.name_key(name)
        return nil if name.nil?

        name = ::Utilities::Nomenclature.unmisspell_name(name)
        return subgenus_epithet(name) if name.match?(SUBGENUS_NAME)

        comparable(name)
      end

      # Splits a CoL authorship string into
      # [verbatim_author, year_of_publication].
      #
      # TaxonWorks Protonym validates that verbatim_author contains no digits,
      # so the year must be stored separately in year_of_publication.
      #
      # CoL provides authorship in two forms:
      #   "Linnaeus, 1758" → author "Linnaeus", year 1758
      #   "(Chatton, 1925) Whittaker & Margulis, 1978" → author "Chatton",
      #     year 1925
      #     (basionym takes precedence when no explicit col_year is given)
      #
      # If no year can be extracted the author string is returned as-is with
      # year nil.
      def self.split_authorship(col_authorship, col_year)
        return [nil, nil] if col_authorship.blank?

        year = col_year.presence&.to_i

        # When authorship leads with "(Basionym Author, YYYY)" and no explicit
        # year was supplied, take author and year from the basionym
        # parenthetical — not the trailing combination authorship.
        if year.nil? && (m = col_authorship.match(/\A\(([^)]+),\s*(\d{4})\)/))
          basionym_author = m[1].gsub(/,?\s*\b\d{4}\b/, '').strip
          basionym_author = nil if basionym_author.blank?
          return [basionym_author, m[2].to_i]
        end

        # Strip any trailing ", YYYY" or " YYYY" from the authorship string.
        # Also strip years embedded inside parenthetical groups, e.g.
        # "(Chatton, 1925)".
        author = col_authorship
          .gsub(/,?\s*\b\d{4}\b/, '') # ", 1925" and " 1925"
          .gsub(/\(\s*\)/, '') # empty parens left behind
          .gsub(/,\s*\z/, '') # trailing comma
          .strip
          .then { |a|
            a.match?(/\A\([^)]*\)\z/) ? a : a.gsub(/\([^)]*\)\s*/, '').strip
          }

        # If no explicit year was given, extract the last 4-digit year from the
        # string (the combination year, not the basionym year in parentheses).
        if year.nil?
          if (m = col_authorship.scan(/\b(\d{4})\b/).last)
            year = m[0].to_i
          end
        end

        author = nil if author.blank?
        [author, year]
      end

      # A TaxonName found by .candidates_by_key, and which of its forms (see
      # .forms) matched: :current or :published.
      Candidate = Struct.new(:taxon_name, :form)

      # The two forms a TaxonWorks name can be written in, which CoL also uses:
      #   * current - #cached, the name as TaxonWorks places it now. Compare
      #     it to CoL names in their current placement, e.g. CoL's accepted
      #     classification.
      #   * published - the name as published: a Protonym's original
      #     combination, or a Combination itself (which has no current form
      #     of its own). CoL lists synonyms this way, while TaxonWorks moves a
      #     synonym under its valid name's parent, so a synonym's #cached can
      #     be a combination that was never published.
      # Which to compare is the caller's decision, and depends on what it's
      # comparing against.
      #
      # @param taxon_name [TaxonName]
      # @return [Hash] { current: String or nil, published: String or nil }
      def self.forms(taxon_name)
        if taxon_name.is_a?(::Combination)
          { current: nil, published: taxon_name.cached }
        else
          {
            current: taxon_name.cached,
            published: taxon_name.cached_original_combination.presence
          }
        end
      end

      # The comparison key of each of a TaxonName's .forms (a subgenus by its
      # epithet).
      #
      # @param taxon_name [TaxonName]
      # @return [Hash] { current: String or nil, published: String or nil }
      def self.taxonworks_name_keys(taxon_name)
        forms(taxon_name).transform_values { |name| name_key(name) }
      end

      # Finds the TaxonNames in project_id one of whose .forms has the key of
      # one of col_rows - which form matched is reported (a name whose two
      # forms share a key is listed once, as :current). Callers still need to
      # check rank (and code) themselves, and decide what a :published match
      # means for them.
      #
      # @param col_rows [Array<Hash>] each with :col_name and :rank
      # @param project_id [Integer]
      # @return [Hash{String => Array<Candidate>}] keyed by comparison key,
      #   only keys of col_rows that have candidates
      def self.candidates_by_key(col_rows, project_id:)
        keys = col_rows
          .map { |row| col_name_key(row[:col_name], row[:rank]) }
          .compact
          .uniq
        return {} if keys.empty?

        t = ::TaxonName.arel_table
        single_word, multi_word = keys.partition { |k| !k.include?(' ') }

        # Exact #cached catches most names (Combinations included); #name
        # catches a subgenus by its epithet, and a misspelled uninomial whose
        # #cached carries [sic].
        condition = t[:cached].in(keys)
          .or(t[:cached_original_combination].in(keys))
        condition = condition.or(t[:name].in(single_word)) if single_word.any?

        # A species-group name may carry a subgenus or [sic] the key doesn't:
        # match #cached on the last epithet (#name) within the genus, and
        # either form on "Genus ... epithet" (the plain "Genus epithet" is
        # matched exactly above). A superset - anything can sit between genus
        # and last epithet, so "Aus bus cus" also finds "Aus xus cus", and
        # "Aus bus" finds "Aus xus bus"; the keys below decide.
        multi_word.each do |k|
          words = k.split(' ')
          genus = ::ActiveRecord::Base.sanitize_sql_like(words.first)
          epithet = ::ActiveRecord::Base.sanitize_sql_like(words.last)
          condition = condition
            .or(t[:name].eq(words.last).and(t[:cached].matches("#{genus} %")))
            .or(t[:cached].matches("#{genus} % #{epithet}"))
            .or(
              t[:cached_original_combination]
                .matches("#{genus} % #{epithet}")
            )
        end

        candidates = Hash.new { |h, k| h[k] = [] }
        ::TaxonName.where(project_id:).where(condition).each do |taxon_name|
          current, published = taxonworks_name_keys(taxon_name)
            .values_at(:current, :published)
          if current
            candidates[current] << Candidate.new(taxon_name, :current)
          end
          if published && published != current
            candidates[published] << Candidate.new(taxon_name, :published)
          end
        end

        candidates.slice(*keys)
      end

      # @param name [String, nil]
      # @return [String, nil]
      def self.comparable(name)
        return nil if name.nil?

        without_subgenus(::Utilities::Nomenclature.unmisspell_name(name))
      end
      private_class_method :comparable

      # Drops every parenthetical, not just a subgenus (an ICZN interpolated
      # species-group name, Art. 6.2, goes too) - fine for a comparison key.
      #
      # @param name [String]
      # @return [String] e.g. "Aedes (Stegomyia) aegypti" => "Aedes aegypti"
      def self.without_subgenus(name)
        name.gsub(/\s*\([^)]*\)/, '').squeeze(' ').strip
      end
      private_class_method :without_subgenus

    end
  end
end

module Vendor
  module Colrapi

    # Translates between how the Catalogue of Life writes a name and how
    # TaxonWorks stores it.
    #
    # CoL's formatting depends on the source dataset (sector) a name came from,
    # and isn't always consistent within one source. What has been seen so far
    # (live CoL, 3LR, 2026-09):
    #   * subgenus: always "Genus (Subgenus)", in search results and
    #     classifications. TaxonWorks stores the bare epithet in #name and
    #     "Genus (Subgenus)" in #cached (ICZN and ICN alike).
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
    #     The single query in .search_term depends on that second half: it's
    #     observed CoL search behavior (2026-10), not documented. If CoL ever
    #     stops matching that way, names CoL gives with a subgenus silently go
    #     missing (e.g. Outdated Names reports them :undeterminable) and specs,
    #     which stub CoL, won't notice - a second query including the subgenus
    #     would then be needed.
    #   * ICN infraspecific names include connecting terms ("Olea europaea
    #     subsp. africana"), same as TaxonWorks #cached.
    #   * [sic] is TaxonWorks-only (#cached), CoL doesn't send it.
    #
    # Names are compared by a "key" computed the same way from both sides; the
    # key is never displayed or used to create anything, though it is what
    # CoL is searched with (.search_term).
    #
    # TODO: ICN section, subsection, series, subseries (and ICZN
    # supersubgenus/infragenus) - TaxonWorks #cached for these is just the
    # genus, so #name would need to be compared, but no CoL examples of these
    # ranks were found to confirm how CoL formats them.
    #
    # TODO: author/year formats likely vary by source in the same way.
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

      # CoL gives a subgenus as "Genus (Subgenus)", TaxonWorks Protonym#name
      # takes just the epithet.
      #
      # @param col_name [String, nil]
      # @return [String, nil]
      def self.subgenus_epithet(col_name)
        ::Utilities::Nomenclature.infrageneric_epithet(col_name)
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

      # @param col_name [String, nil] a name as CoL gives it (a subgenus may
      #   already be reduced to its epithet)
      # @param rank [String, nil] CoL rank name, e.g. 'subgenus'
      # @return [String, nil] the comparison key for col_name
      def self.col_key(col_name, rank)
        return nil if col_name.nil?
        return subgenus_epithet(col_name) if rank == 'subgenus'

        comparable(col_name)
      end

      # The comparison key for a name given as text on the TaxonWorks side -
      # use only when there's no TaxonName (else see .current_form_key).
      #
      # @param name [String, nil]
      # @return [String, nil]
      def self.name_key(name)
        return nil if name.nil?
        return subgenus_epithet(name) if name.strip.match?(/\A\S+ \([^)]+\)\z/)

        comparable(name)
      end

      # The form of a TaxonName to look it up in CoL by. An invalid Protonym is
      # its original combination: TaxonWorks moves a synonym under its valid
      # name's parent, so its #cached can be a combination that was never
      # published, while CoL lists synonyms as they were published. (Compare
      # .current_form_key, which is always the current form.)
      #
      # @param taxon_name [TaxonName]
      # @return [String, nil]
      def self.col_lookup_name(taxon_name)
        if taxon_name.is_a?(::Protonym) && !taxon_name.cached_is_valid
          taxon_name.cached_original_combination.presence || taxon_name.cached
        else
          taxon_name.cached
        end
      end

      # The comparison key for a TaxonName's current form: #cached, i.e. the
      # name as TaxonWorks places it now (a subgenus by its epithet). Compare
      # it to CoL names in their current placement too, e.g. CoL's accepted
      # classification. It is not how CoL lists a synonym: CoL gives
      # synonyms as published, while TaxonWorks moves a synonym under its
      # valid name's parent - use .col_lookup_name for that form.
      #
      # @param taxon_name [TaxonName]
      # @return [String, nil]
      def self.current_form_key(taxon_name)
        if ::RANKS_LOOKUP[taxon_name.rank_class.to_s] == 'subgenus'
          taxon_name.name
        else
          comparable(taxon_name.cached)
        end
      end

      # Finds the TaxonNames in project_id whose current form (see
      # .current_form_key) matches the key of one of col_rows. Callers still
      # need to check rank (and code) themselves.
      #
      # TODO: a CoL row for a name as published (e.g. a synonym CoL lists in
      # its original combination, "Aphrodes dobrogicus") misses the
      # TaxonName whose current form differs (TaxonWorks "Planaphrodes
      # dobrogica") - #cached_original_combination is never searched, valid
      # and invalid names alike (e.g. valid "Vilargus pumilicans", orig.
      # "Deltocephalus pumilicans"). See the duplicate-creation TODO in
      # Autoselect::TaxonName::Levels::CatalogueOfLife#match_against_taxonworks:
      # such a hit should be reported, not become an anchor.
      #
      # @param col_rows [Array<Hash>] each with :col_name and :rank
      # @param project_id [Integer]
      # @return [Hash{String => Array<TaxonName>}] keyed by comparison key,
      #   only keys of col_rows that have candidates
      def self.candidates_by_key(col_rows, project_id:)
        keys = col_rows
          .map { |row| col_key(row[:col_name], row[:rank]) }
          .compact
          .uniq
        return {} if keys.empty?

        t = ::TaxonName.arel_table
        single_word, multi_word = keys.partition { |k| !k.include?(' ') }

        # Exact #cached catches most names; #name catches a subgenus by its
        # epithet.
        condition = t[:cached].in(keys)
        condition = condition.or(t[:name].in(single_word)) if single_word.any?

        # A species-group #cached may carry a subgenus or [sic] the key
        # doesn't, so match on the last epithet (#name) within the genus.
        multi_word.each do |k|
          words = k.split(' ')
          genus_prefix =
            "#{::ActiveRecord::Base.sanitize_sql_like(words.first)} %"
          condition = condition.or(
            t[:name].eq(words.last).and(t[:cached].matches(genus_prefix))
          )
        end

        ::TaxonName.where(project_id:).where(condition)
          .group_by { |taxon_name| current_form_key(taxon_name) }
          .slice(*keys)
      end

      # @param name [String, nil]
      # @return [String, nil]
      def self.comparable(name)
        return nil if name.nil?

        ::Utilities::Nomenclature.without_infrageneric_epithet(
          ::Utilities::Nomenclature.unmisspell_name(name)
        )
      end
      private_class_method :comparable

    end
  end
end

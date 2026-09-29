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
    #   * ICN infraspecific names include connecting terms ("Olea europaea
    #     subsp. africana"), same as TaxonWorks #cached.
    #   * [sic] is TaxonWorks-only (#cached), CoL doesn't send it.
    #
    # Names are compared by a "key" computed the same way from both sides; the
    # key is never displayed or used to create anything.
    #
    # TODO: ICN section, subsection, series, subseries (and ICZN
    # supersubgenus/infragenus) - TaxonWorks #cached for these is just the
    # genus, so #name would need to be compared, but no CoL examples of these
    # ranks were found to confirm how CoL formats them.
    #
    # TODO: author/year formats likely vary by source in the same way.
    #
    # Claude (Anthropic) provided > 50% of the code for this module.
    module NameTranslation

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

      # @param taxon_name [TaxonName]
      # @return [String, nil] the comparison key for taxon_name
      def self.taxon_name_key(taxon_name)
        if ::RANKS_LOOKUP[taxon_name.rank_class.to_s] == 'subgenus'
          taxon_name.name
        else
          comparable(taxon_name.cached)
        end
      end

      # Finds the TaxonNames in project_id whose key matches the key of one of
      # col_rows. Callers still need to check rank (and code) themselves.
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
          .group_by { |taxon_name| taxon_name_key(taxon_name) }
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

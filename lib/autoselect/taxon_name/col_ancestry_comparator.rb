module Autoselect
  module TaxonName
    # Diffs TaxonWorks' real ancestor chain for a matched "anchor" TaxonName
    # against Catalogue of Life's classification for the same lineage,
    # producing one unified, kingdom-first row list.
    #
    # CoL gives ranks as plain names (e.g. 'family'), so each TaxonWorks
    # rank_class is converted to its plain name (via RANKS_LOOKUP) to see
    # whether two rows are at the same rank.
    #
    # To decide which of two different ranks is more specific, both names are
    # looked up under one code. When CoL gives a code, the TaxonWorks chain is
    # already in it, so that code is used; otherwise the anchor's own code is.
    class ColAncestryComparator

      # @param tw_chain [Array<TaxonName>] kingdom-first, the anchor and its
      #   real ancestors (excluding the project root / non-taxonomic node)
      # @param col_chain [Array<Hash>] kingdom-first, CoL's classification up
      #   to and including the anchor's own rank; each hash has :col_name,
      #   :rank (human rank name, e.g. 'family'), :col_id, :dataset_id,
      #   :col_authorship, :above_genus_group, :rank_unknown
      # @param col_code [String, nil] CoL nomenclatural code ('zoological',
      #   'botanical', …)
      def initialize(tw_chain:, col_chain:, col_code: nil)
        @tw_chain = tw_chain
        @col_chain = col_chain
        @rank_code =
          if ::Vendor::Colrapi::COL_CODE_LOOKUP_MAP.key?(col_code)
            col_code
          else
            anchor_col_code
          end
      end

      # @return [Array<Hash>] kingdom-first, each row tagged
      #   :match => 'exact' | 'none' (CoL-only, to be created) | 'extra'
      #   (TaxonWorks-only) | 'conflict' (same rank, different name — the
      #   actual disagreement)
      def call
        result = []
        tw_i = @tw_chain.length - 1
        col_i = @col_chain.length - 1

        while tw_i >= 0 && col_i >= 0
          tw_entry = @tw_chain[tw_i]
          col_entry = @col_chain[col_i]
          tw_rank_name = rank_name_for(tw_entry.rank_class)

          if tw_rank_name == col_entry[:rank]
            result.unshift(matched_row(tw_entry, col_entry, tw_rank_name))
            tw_i -= 1
            col_i -= 1
          elsif more_specific?(tw_entry, col_entry[:rank])
            result.unshift(extra_row(tw_entry, tw_rank_name))
            tw_i -= 1
          else
            result.unshift(none_row(col_entry))
            col_i -= 1
          end
        end

        while tw_i >= 0
          entry = @tw_chain[tw_i]
          result.unshift(extra_row(entry, rank_name_for(entry.rank_class)))
          tw_i -= 1
        end

        while col_i >= 0
          result.unshift(none_row(@col_chain[col_i]))
          col_i -= 1
        end

        result
      end

      private

      def rank_name_for(rank_class)
        ::RANKS_LOOKUP[rank_class.to_s]
      end

      # @return [String, nil] the anchor's nomenclatural code as a CoL code
      #   string, e.g. 'botanical'; nil leaves col_rank_sort on its zoological
      #   default
      def anchor_col_code
        code = @tw_chain.last&.rank_class&.nomenclatural_code
        ::Vendor::Colrapi::COL_CODE_TO_NOMENCLATURE_CODE.key(code)
      end

      # The TaxonWorks chain is always in @rank_code's code (see the class
      # comment), so tw_entry's own rank_class indexes RANK_SORT directly; only
      # CoL's rank name can fail to resolve under that code.
      #
      # @return [Boolean] true when tw_entry's rank is narrower (more specific)
      #   than col_rank_name, i.e. TaxonWorks' pointer hasn't reached CoL's
      #   rank yet. An unresolvable CoL rank is treated as not-more-specific,
      #   so CoL's side advances and the row shows up as 'none'.
      def more_specific?(tw_entry, col_rank_name)
        col_sort = ::Vendor::Colrapi.col_rank_sort(col_rank_name, @rank_code)
        return false if col_sort.nil?

        ::RANK_SORT[tw_entry.rank_class.to_s] > col_sort
      end

      def matched_row(tw_entry, col_entry, rank_name)
        # Compared by key, not raw name - see Vendor::Colrapi::NameTranslation.
        translation = ::Vendor::Colrapi::NameTranslation
        exact = translation.taxonworks_name_keys(tw_entry)[:current] ==
          translation.col_name_key(col_entry[:col_name], col_entry[:rank])

        {
          rank: rank_name,
          col_name: col_entry[:col_name],
          col_id: col_entry[:col_id],
          dataset_id: col_entry[:dataset_id],
          col_authorship: col_entry[:col_authorship],
          taxonworks_id: tw_entry.id,
          taxonworks_name: tw_entry.cached,
          match: exact ? 'exact' : 'conflict'
        }
      end

      def extra_row(tw_entry, rank_name)
        {
          rank: rank_name,
          col_name: nil,
          col_id: nil,
          dataset_id: nil,
          col_authorship: nil,
          taxonworks_id: tw_entry.id,
          taxonworks_name: tw_entry.cached,
          match: 'extra'
        }
      end

      def none_row(col_entry)
        {
          rank: col_entry[:rank],
          col_name: col_entry[:col_name],
          col_id: col_entry[:col_id],
          dataset_id: col_entry[:dataset_id],
          col_authorship: col_entry[:col_authorship],
          above_genus_group: col_entry[:above_genus_group],
          rank_unknown: col_entry[:rank_unknown],
          taxonworks_id: nil,
          taxonworks_name: nil,
          match: 'none'
        }
      end

    end
  end
end

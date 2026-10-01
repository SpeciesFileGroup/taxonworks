module Autoselect
  module TaxonName
    # Diffs TaxonWorks' real ancestor chain for a matched "anchor" TaxonName
    # against Catalogue of Life's classification for the same lineage,
    # producing one unified, kingdom-first row list.
    #
    # Ranks are matched by plain rank name (e.g. 'family'), which both sides
    # share, not by TaxonWorks rank_class, which differs by nomenclatural code
    # (an ICZN Family and an ICN Family are different classes).
    #
    # To decide which of two different ranks is more specific, both names are
    # looked up under one code - CoL's, via Vendor::Colrapi.col_rank_sort.
    # RANK_SORT numbers every code's ranks in a single sequence, so a
    # zoological index can't be compared with a botanical one; looking both
    # names up under the same code keeps the comparison valid even when the
    # TaxonWorks name was entered under a different code than CoL's.
    class ColAncestryComparator

      # @param tw_chain [Array<TaxonName>] kingdom-first, the anchor and its
      #   real ancestors (excluding the project root / non-taxonomic node)
      # @param col_chain [Array<Hash>] kingdom-first, CoL's classification up
      #   to and including the anchor's own rank; each hash has :col_name,
      #   :rank (human rank name, e.g. 'family'), :col_id, :dataset_id,
      #   :col_authorship, :above_genus_group
      # @param col_code [String, nil] CoL nomenclatural code ('zoological',
      #   'botanical', …)
      def initialize(tw_chain:, col_chain:, col_code: nil)
        @tw_chain = tw_chain
        @col_chain = col_chain
        @col_code = col_code
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
          elsif more_specific?(tw_rank_name, col_entry[:rank])
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

      # @return [Boolean] true when tw_rank_name is a narrower (more specific)
      #   rank than col_rank_name, i.e. TaxonWorks' pointer hasn't reached
      #   CoL's rank yet. Unresolvable ranks (nil sort) are treated as
      #   not-more-specific.
      def more_specific?(tw_rank_name, col_rank_name)
        tw_sort = ::Vendor::Colrapi.col_rank_sort(tw_rank_name, @col_code)
        col_sort = ::Vendor::Colrapi.col_rank_sort(col_rank_name, @col_code)
        return false if tw_sort.nil? || col_sort.nil?

        tw_sort > col_sort
      end

      def matched_row(tw_entry, col_entry, rank_name)
        # Compared by key, not raw name - see Vendor::Colrapi::NameTranslation.
        translation = ::Vendor::Colrapi::NameTranslation
        exact = translation.taxon_name_key(tw_entry) ==
          translation.col_key(col_entry[:col_name], col_entry[:rank])

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
          taxonworks_id: nil,
          taxonworks_name: nil,
          match: 'none'
        }
      end

    end
  end
end

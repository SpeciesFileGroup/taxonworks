module Autoselect
  module TaxonName
    # Diffs TaxonWorks' real ancestor chain for a matched "anchor" TaxonName against
    # Catalogue of Life's classification for the same lineage, producing one unified,
    # kingdom-first row list — instead of matching each CoL rank to TaxonWorks
    # independently by name (see Vendor::Colrapi.build_extension), which can silently
    # stitch together matches from genuinely unrelated lineages.
    #
    # Ranks are compared by their CoL-rank NAME (e.g. 'family'), not by TaxonWorks
    # rank_class string, and ordered via Vendor::Colrapi.col_rank_sort against a single
    # nomenclatural code throughout — this keeps ordering comparisons meaningful even
    # though TaxonWorks concatenates each code's ranks into one non-comparable numbering
    # (see RANK_SORT), and lets e.g. an ICN-coded TaxonWorks family compare correctly
    # against an ICZN-translated CoL family.
    class ColAncestryComparator

      # @param tw_chain [Array<TaxonName>] kingdom-first, the anchor and its real
      #   ancestors (excluding the project root / non-taxonomic node)
      # @param col_chain [Array<Hash>] kingdom-first, CoL's classification up to and
      #   including the anchor's own rank; each hash has :col_name, :rank (human
      #   rank name, e.g. 'family'), :col_id, :dataset_id, :col_authorship,
      #   :above_genus_group (passed through on 'none' rows only — the client only
      #   needs it to default those rows' checkboxes)
      # @param col_code [String, nil] CoL nomenclatural code ('zoological', 'botanical', …)
      def initialize(tw_chain:, col_chain:, col_code: nil)
        @tw_chain = tw_chain
        @col_chain = col_chain
        @col_code = col_code
      end

      # @return [Array<Hash>] kingdom-first, each row tagged :match => 'exact' | 'none'
      #   (CoL-only, to be created) | 'extra' (TaxonWorks-only) | 'conflict' (same rank,
      #   different name — the actual disagreement)
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
        # TaxonName#rank_class returns the constantized Class, not the string RANKS_LOOKUP
        # is keyed by (Rails happens to print a Class identically to its name, which is easy
        # to mistake for a String at a glance — confirm with #class, not just #inspect/puts).
        ::RANKS_LOOKUP[rank_class.to_s]
      end

      # @return [Boolean] true when tw_rank_name is a narrower (more specific) rank than
      #   col_rank_name, i.e. TaxonWorks' pointer hasn't reached CoL's rank yet. Unresolvable
      #   ranks (nil sort) are treated as not-more-specific, so the CoL side advances instead
      #   — that just means the row shows up as a plain 'none' rather than blocking the diff.
      def more_specific?(tw_rank_name, col_rank_name)
        tw_sort = ::Vendor::Colrapi.col_rank_sort(tw_rank_name, @col_code)
        col_sort = ::Vendor::Colrapi.col_rank_sort(col_rank_name, @col_code)
        return false if tw_sort.nil? || col_sort.nil?
        tw_sort > col_sort
      end

      def matched_row(tw_entry, col_entry, rank_name)
        exact = tw_entry.cached == col_entry[:col_name]
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

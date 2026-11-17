# Merges Match::Otu::TaxonName's per-name results with Match::Otu::MorphospeciesName's
# (same order, both preserve input order). A TaxonName match's taxon_name/otus are
# never altered by an OTU-name match - the latter only tags `match_source` for
# display/filtering. When both matched, the row is flagged ambiguous: the curator
# has two plausible identifications (the TaxonName match and the OTU-name match) to
# choose between, regardless of whether either matcher found ambiguity on its own.
#
# Usage:
#   Match::Otu::MergeResults.new(tn_results:, otu_results:).call
module Match
  module Otu
    class MergeResults

      attr_reader :tn_results, :otu_results

      # @param tn_results [Array<Hash>] Match::Otu::TaxonName#call results
      # @param otu_results [Array<Hash>] Match::Otu::MorphospeciesName#call results, same
      #   size and input order as tn_results
      def initialize(tn_results:, otu_results:)
        @tn_results = tn_results
        @otu_results = otu_results
      end

      # @return [Array<Hash>]
      def call
        tn_results.zip(otu_results).map do |tn, otu|
          if tn[:matched]
            if otu[:matched]
              tn.merge(match_source: 'both', ambiguous: true)
            else
              tn.merge(match_source: 'taxon_name')
            end
          elsif otu[:matched]
            otu.merge(scientific_name: tn[:scientific_name], match_source: 'otu')
          else
            tn.merge(match_source: nil)
          end
        end
      end
    end
  end
end

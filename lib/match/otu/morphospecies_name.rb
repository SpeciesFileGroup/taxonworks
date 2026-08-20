# Matches an array of name strings, each expected to be an exact "Genus otu_name" pair
# (e.g. a morphospecies code like "Tapinoma CASC_2231"), to existing Otu records.
#
# Unlike Match::Otu::TaxonName this is exact-match only: no fuzzy distance, no subgenus
# retry, no synonym resolution, no candidates list. Both the genus and the otu name must
# match exactly.
#
# Usage:
#   result = Match::Otu::MorphospeciesName.new(
#     names: ['Aus bus', 'Cus dus'],
#     project_id: 1,
#     taxon_name_id: nil
#   ).call
#
# Returns an Array of Hashes, one per input name:
#   [
#     {
#       scientific_name: 'Aus bus',
#       taxon_name_id: 123,   # the matched Otu's genus
#       taxon_name: <TaxonName>,
#       otus: [<Otu>, ...],
#       ambiguous: false,
#       matched: true
#     }, ...
#   ]
module Match
  module Otu
    class MorphospeciesName
      include NameBatchMatcher

      attr_reader :names, :project_id, :taxon_name_id

      # @param names [Array<String>] array of name strings to match
      # @param project_id [Integer]
      # @param taxon_name_id [Integer, nil] scope matches to descendants of this TaxonName
      def initialize(names:, project_id:, taxon_name_id: nil)
        @names = names.first(NameBatchMatcher::MAX_NAMES)
        @project_id = project_id
        @taxon_name_id = taxon_name_id
      end

      private

      # @param name [String]
      # @return [Hash]
      def match_name(name)
        genus_term, otu_term = ::Otu.split_morphospecies_name(name)
        return no_match unless genus_term

        otus = ::Queries::Otu::Filter.new(
          genus_name: genus_term,
          name: otu_term,
          name_exact: true,
          taxon_name_id:,
          descendants: taxon_name_id.present?,
          project_id:
        ).all.eager_load(:taxon_name).to_a

        return no_match if otus.empty?

        {
          taxon_name_id: otus.first.taxon_name_id,
          taxon_name: otus.first.taxon_name,
          otus:,
          ambiguous: otus.map(&:taxon_name_id).uniq.size > 1, # homonym genera, or stray duplicate Otu rows
          matched: true
        }
      end

      # @return [Hash]
      def no_match
        { taxon_name_id: nil, taxon_name: nil, otus: [], ambiguous: false, matched: false }
      end
    end
  end
end

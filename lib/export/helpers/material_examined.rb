# TaxonWorks wrapper that bridges native DwcOccurrence data to
# Utilities::MaterialExamined for rendering.
#
# Usage:
#   text = Export::Helpers::MaterialExamined.render_for_otu(otu)
#
module Export
  module Helpers
    module MaterialExamined

      # @param otu [Otu]
      # @param dwc_scope [ActiveRecord::Relation, nil]
      #   Optional pre-filtered DwcOccurrence scope. When nil,
      #   defaults to all occurrences for the OTU including synonymy.
      # @param order [Array<Symbol>]
      #   Nesting order forwarded to Utilities::MaterialExamined.
      # @param augmentations [Hash]
      #   Occurrence-level additions keyed by occurrenceID, forwarded verbatim.
      # @return [String] Markdown-formatted material examined text
      def self.render_for_otu(otu, dwc_scope: nil, order: ::Utilities::MaterialExamined::DEFAULT_ORDER, augmentations: {})
        scope = dwc_scope || ::DwcOccurrence.scoped_by_otu(otu)
        occurrences = scope.map(&:dwc_json)
        return '' if occurrences.empty?

        ::Utilities::MaterialExamined.new(
          occurrences,
          order:,
          augmentations:
        ).render
      end

    end
  end
end

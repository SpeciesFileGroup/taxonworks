# TaxonWorks wrapper that bridges native DwcOccurrence data to
# Utilities::MaterialExamined for rendering.
#
# Usage:
#   renderer = Export::Helpers::MaterialExamined.renderer_for_otu(otu, order: [...], todo: false)
#   text     = renderer.render
#   ids      = renderer.todo_occurrence_ids  # non-empty only when todo: true
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
      #   Occurrence-level additions keyed by occurrenceID. When todo: true the
      #   wrapper merges edit_link values built from each DwcOccurrence record;
      #   callers may pass additional augmentation data (e.g. :label) which is
      #   preserved.
      # @param todo [Boolean]
      #   When true, blank active-field values render as "[TODO]" and
      #   todo_occurrence_ids is populated on the returned renderer.
      # @return [Utilities::MaterialExamined]
      def self.renderer_for_otu(otu, dwc_scope: nil, order: ::Utilities::MaterialExamined::DEFAULT_ORDER, augmentations: {}, todo: false)
        scope       = dwc_scope || ::DwcOccurrence.scoped_by_otu(otu)
        occurrences = scope.map(&:dwc_json)
        return ::Utilities::MaterialExamined.new([], order:, augmentations:, todo:) if occurrences.empty?

        merged_augmentations = build_augmentations(scope).merge(augmentations)

        ::Utilities::MaterialExamined.new(
          occurrences,
          order:,
          augmentations: merged_augmentations,
          todo:
        )
      end

      # Convenience wrapper that returns rendered Markdown directly.
      def self.render_for_otu(otu, dwc_scope: nil, order: ::Utilities::MaterialExamined::DEFAULT_ORDER, augmentations: {})
        renderer_for_otu(otu, dwc_scope:, order:, augmentations:, todo: false).render
      end

      private_class_method def self.build_augmentations(scope)
        scope.each_with_object({}) do |dwc, hash|
          occ_id = dwc.occurrenceID
          next if occ_id.blank?
          hash[occ_id] = {
            label:     dwc.catalogNumber.presence || occ_id,
            edit_link: edit_link_for(dwc)
          }
        end
      end

      private_class_method def self.edit_link_for(dwc)
        id = dwc.dwc_occurrence_object_id
        case dwc.dwc_occurrence_object_type
        when 'CollectionObject'
          "/tasks/accessions/comprehensive?collection_object_id=#{id}"
        when 'FieldOccurrence'
          "/tasks/field_occurrences/browse?field_occurrence_id=#{id}"
        when 'AssertedDistribution'
          "/tasks/asserted_distributions/new_asserted_distribution?asserted_distribution_id=#{id}"
        end
      end

    end
  end
end

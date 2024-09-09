# Add hooks to ensure record changes trigger re-indexing at DwcOccurrence
#
# Models including this concern must implement:
#
#   def ddwc_occrences
#     DwcOccurrence.<select>
#   end
#
module Shared::DwcOccurrenceHooks
  extend ActiveSupport::Concern

  included do

    # @return [Boolean]
    #   When true, will not rebuild dwc_occurrence index.
    #   See also Shared::IsDwcOccurrence
    attr_accessor :no_dwc_occurrence

    after_save_commit :update_dwc_occurrence, if: :saved_changes?, unless: :no_dwc_occurrence
    after_destroy :update_dwc_occurrence

    def update_dwc_occurrence

      t = dwc_occurrences.count
      q = dwc_occurrences.unscope(:select).select('dwc_occurrences.id', 'occurrenceID', :dwc_occurrence_object_type, :dwc_occurrence_object_id)

      q.find_each do |d|
        if t > 100
          delay(queue: :dwc_occurrence_index).delay_dwc_reindex(d.dwc_occurrence_object)
        else
          d.dwc_occurrence_object.set_dwc_occurrence
        end
      end
    end

    def delay_dwc_reindex(object)
      object.set_dwc_occurrence
    end

  end

end

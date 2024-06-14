# Add hooks to ensure record changes trigger re-indexing at DwcOccurrence
module Shared::DwcOccurrenceHooks

  extend ActiveSupport::Concern

  included do

    after_save_commit :update_dwc_occurrence, if: :saved_changes?

    def update_dwc_occurrence
      t = dwc_occurrences.count

      dwc_occurrences.find_each do |d|
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

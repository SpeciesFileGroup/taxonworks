# Add hooks to ensure record changes trigger re-indexing at DwcOccurrence.
#
# Models including this concern must implement:
#
#   def dwc_occurrences
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

    after_commit :update_dwc_occurrence, unless: :no_dwc_occurrence

#   after_save_commit :update_dwc_occurrence, unless: :no_dwc_occurrence
#   around_destroy :process_destroy

    def update_dwc_occurrence
      t = dwc_occurrences.count
      return if t == 0

      rebuild_set = SecureRandom.hex(10)

      begin
        # If the scope is returning every object at this point (arbitrary cutoff), then the scope is badly coded.
        raise TaxonWorks::Error if t > 20_000 && (t == DwcOccurrence.where(project_id:).count)

        dwc_occurrences.in_batches do |b|
          b.update_all(rebuild_set:) # Mark the set of records requiring rebuild
        end

        priority = case t
                   when 1..100
                     1
                   when 101..1000
                     2
                   else
                     6
                   end

        ::DwcOccurrenceRefreshJob.set(priority:).perform_later(
          rebuild_set:, 
          user_id: Current.user_id,
        )

      rescue => e
        ExceptionNotifier.notify_exception(
          e,
          data: {
            message: "Improperly coded scope dwc_occurrences rebuild #{self.class.name}",
            object_id: id,
            object_class: self.class.name,
          }
        )
        raise
      end
    end

  end

end

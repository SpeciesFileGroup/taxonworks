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

    after_save_commit :update_dwc_occurrence, unless: :no_dwc_occurrence
    around_destroy :process_destroy

    def update_dwc_occurrence
      t = dwc_occurrences.count

      begin
        # If the scope is returning every object at this point (arbitrarily > 5k records), then the scope is badly coded.
        raise TaxonWorks::Error if t > 5000 && (t == DwcOccurrence.where(project_id:).count)

        if t < 100
          q = dwc_occurrences.reselect('dwc_occurrences.id', :occurrenceID, :dwc_occurrence_object_type, :dwc_occurrence_object_id, :is_flagged_for_rebuild)

          q.find_each do |d|
            d.dwc_occurrence_object.set_dwc_occurrence
          end
        else

          # `update_all` fails because of missing .from() support, see
          # dwc_occurrences.update_all(is_flagged_for_rebuild: true) # Quickly mark all records requiring rebuild

          dwc_occurrences.in_batches do |b|
            b.update_all(is_flagged_for_rebuild: true) # Quickly mark all records requiring rebuild
          end

          ::DwcOccurrenceRefreshJob.perform_later(project_id:, user_id: Current.user_id)
        end

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

    def process_destroy
      t = dwc_occurrences.count

      to_be_processed_now = nil
      if t < 50
        to_be_processed_now = dwc_occurrences.select(:id, :occurrenceID,
          :dwc_occurrence_object_type, :dwc_occurrence_object_id).to_a
      else
        ::DwcOccurrence
          .where(id: dwc_occurrences.reselect(:id))
          .update_all(is_flagged_for_rebuild: true)
      end

      yield # destroy

      if to_be_processed_now.any?
        to_be_processed_now.each { |d|
          d.dwc_occurrence_object.set_dwc_occurrence
        }
      else
        ::DwcOccurrenceRefreshJob
          .perform_later(project_id:, user_id: Current.user_id)
      end
    end

    def delay_dwc_reindex(object)
      object.set_dwc_occurrence
    end

  end

end

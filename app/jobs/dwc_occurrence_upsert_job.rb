class DwcOccurrenceUpsertJob < ApplicationJob
  queue_as :dwc_occurrence_index

  def perform(collection_object)
    collection_object&.collecting_event&.set_cached
    collection_object.set_dwc_occurrence
  end
end

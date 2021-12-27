class DwcOccurrenceUpsertJob < ApplicationJob
  queue_as :dwc_occurrence_index

  def perform(collection_object)
    collection_object.georeferences.each { |g| g.send(:set_cached) }
    collection_object.set_dwc_occurrence
  end
end

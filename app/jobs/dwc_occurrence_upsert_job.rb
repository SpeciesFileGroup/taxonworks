class DwcOccurrenceUpsertJob < ApplicationJob
  queue_as :dwc_occurrence_index

  def perform(object)
    object.set_dwc_occurrence
  end
end

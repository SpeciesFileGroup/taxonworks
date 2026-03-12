class DwcOccurrenceRefreshJob < ApplicationJob
  queue_as :query_batch_update

  def max_run_time
    2.hours
  end

  def max_attempts
    2
  end

  # @parapm rebuild_set
  #   arbitrary set name, a random string
  def perform(rebuild_set: nil, user_id: nil)
    raise TaxonWorks::Error, 'no set id to refresh job' if rebuild_set.blank?

    q = DwcOccurrence
      .where(rebuild_set:)
      .includes(
        dwc_occurrence_object: [
          :images,
          :identifiers,
          :type_materials,
          :preparation_type,
          :taxon_determinations,
          :current_taxon_determination,
          :biocuration_classifications,
          { collecting_event: [:georeferences, { collector_roles: :person }, :geographic_area] }
        ]
      )

    q.find_each do |o|

      begin
        o.dwc_occurrence_object.send(:set_dwc_occurrence)
      rescue => ex
        ExceptionNotifier.notify_exception(
          ex,
          data: { user_id:}
        )
        raise
      end
    end

  end
end

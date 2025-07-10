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

    q = DwcOccurrence.where(rebuild_set:)

    Current.user_id = user_id

    q.all.find_each do |o|

      begin
        o.dwc_occurrence_object.send(:set_dwc_occurrence)
      rescue => ex
        ExceptionNotifier.notify_exception(
          ex,
          data: { project_id:, user_id:}
        )
        raise
      end
    end

  end
end

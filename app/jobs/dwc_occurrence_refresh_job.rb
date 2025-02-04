class DwcOccurrenceRefreshJob < ApplicationJob
  queue_as :query_batch_update

  def max_run_time
    2.hours
  end

  def max_attempts
    2
  end

  def perform(project_id: nil, user_id: nil)
    q = DwcOccurrence.where(project_id:, is_flagged_for_rebuild: true)

    Current.user_id = user_id
    q.all.find_each do |o|
      begin
        o.dwc_occurrence_object.send(:set_dwc_occurrence)
      rescue =>  ex
        ExceptionNotifier.notify_exception(
          ex,
          data: { project_id:, user_id:}
        )
        raise
      end
    end

  end
end

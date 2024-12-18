class DwcOccurrenceRefreshJob < ApplicationJob
  queue_as :query_batch_update

  def max_run_time
    2.hour
  end

  def max_attempts
    2
  end

  def perform(project_id: nil, user_id: nil)
    q = DwcOccurrence.where(project_id:, is_stale: true)
    q.all.find_each do |o|
      begin
        Current.user_id = user_id # Jobs are run in different threads, in theory.
        o.dwc_occurrence_object.send(:set_dwc_occurrence)
      rescue =>  ex
        ExceptionNotifier.notify_exception(
          ex,
          data: { project_id:, user_id:}
        )
        raise
      end
    end
    q.all.update_all(is_stale: nil)
  end
end

class BatchByFilterScopeJob < ApplicationJob
  queue_as :query_batch_update

  def max_run_time
    1.hour
  end

  def max_attempts
    1
  end

  # At this point filter_query is already validated as good in terms of params, etc., see identifier.rb e.g.
  def perform(
    batch_response: nil, klass: nil, hash_query: nil, mode: nil, params: nil,
    project_id: nil, user_id: nil
  )
    begin
      # Set a 'session' context in this background job:
      Current.user_id = user_id
      Current.project_id = project_id

      b = ::Queries::Query::Filter.instantiated_base_filter(hash_query)
      q = b.all(true)

      # Unused for now, but could be utilized for background job feedback at
      # some point.
      r = ::BatchResponse.new(
        preview: false,
        method: "#{klass} batch_by_filter_scope async"
      )

      klass.constantize.process_batch_by_filter_scope(
        batch_response: r,
        query: q,
        hash_query:,
        mode:,
        params:,
        project_id:,
        user_id:,
        called_from_async: true
      )

    rescue  => ex
      ExceptionNotifier.notify_exception(
        ex,
        data: { project_id:, filter_query:, mode:, params: }
      )
      raise
    end
  end
end

class IdentifierBatchJob < ApplicationJob
  queue_as :query_batch_update

  def max_run_time
    1.hour
  end

  def max_attempts
    1
  end

  # At this point filter_query is already validated as good in terms of params, etc., see confidence.rb
  def perform(filter_query: nil, params: nil, mode: nil, project_id: nil, user_id: nil)
    begin
      b = ::Queries::Query::Filter.instantiated_base_filter(filter_query)
      q = b.all(true)

      case mode
      when :replace
        klass = b.referenced_klass.name
        Identifier
          .with(a: q.select(:id))
          .joins('JOIN a ON identifiers.identifier_object_id = a.id AND ' \
                 "identifiers.identifier_object_type = '#{klass}'")
          .where(type: params[:identifier_types])
          #.where.not(namespace_id: params.namespace_id)
          .distinct
          .find_each do |o|
            o.update(namespace_id: params[:namespace_id])
          end
      end

    rescue  => ex
      ExceptionNotifier.notify_exception(
        ex,
        data: { project_id:, filter_query:, mode:, params: }
      )
      raise
    end
  end
end

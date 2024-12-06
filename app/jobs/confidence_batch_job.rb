class ConfidenceBatchJob < ApplicationJob
  queue_as :query_batch_update

  def max_run_time
    1.hour
  end

  def max_attempts
    1
  end

  # At this point filter_query is already validated as good in terms of params, etc., see confidence.rb
  def perform(filter_query: nil, confidence_level_id: nil, replace_confidence_level_id: nil, mode: nil, project_id: nil, user_id: nil)
    begin
      q = ::Queries::Query::Filter.instantiated_base_filter(filter_query)

      case mode
      when :add
        q.all.find_each do |o|
          Confidence.create(
            confidence_object: o,
            confidence_level_id:,
            by: user_id,
            project_id:,
          )
        end

      when :replace
        Confidence
          .where(
            confidence_object_id: q.all.pluck(:id),
            confidence_object_type: q.referenced_klass.name,
            confidence_object_type: q.referenced_klass.base_class.name,
            confidence_level_id: replace_confidence_level_id
          ).find_each do |c|
            c.update(confidence_level_id:)
          end
      end

    rescue  => ex
      ExceptionNotifier.notify_exception(
        ex,
        data: { project: target_project&.id, download: download&.id&.to_s }
      )
      raise
    end
  end
end

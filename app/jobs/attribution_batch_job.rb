class AttributionBatchJob < ApplicationJob
  queue_as :query_batch_update

  def max_run_time
    1.hour
  end

  def max_attempts
    1
  end

  # At this point filter_query is already validated as good in terms of params, etc., see Attribution.rb
  def perform(filter_query: nil, params: nil, mode: nil, project_id: nil, user_id: nil)
    begin
      q = ::Queries::Query::Filter.instantiated_base_filter(filter_query)
      attribution_object_type = q.referenced_klass.base_class.name

      case mode
      when :add
        q.all.find_each do |o|
          Attribution.create(
            params.merge({
              attribution_object_id: o.id,
              attribution_object_type:
            })
          )
        end

      # when :replace
      #   Attribution
      #     .where(
      #       Attribution_object_id: q.all.pluck(:id),
      #       Attribution_object_type: q.referenced_klass.base_class.name,
      #       Attribution_level_id: replace_Attribution_level_id
      #     ).find_each do |c|
      #       c.update(
      #         Attribution_level_id:,
      #         by: user_id
      #       )
      #     end
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

class ProtocolRelationshipBatchJob < ApplicationJob
  queue_as :query_batch_update

  def max_run_time
    1.hour
  end

  def max_attempts
    1
  end

  def perform(filter_query: nil, confidence_level_id: nil, protocol_id: nil, replace_protocol_id: nil, mode: nil, project_id: nil, user_id: nil)
    begin
      q = ::Queries::Query::Filter.instantiated_base_filter(filter_query)

      case mode
      when :add
        q.all.find_each do |o|
          ProtocolRelationship.create(
            protocol_relationship_object: o,
            protocol_id:,
            by: user_id,
            project_id:,
          )
        end

      when :replace
       ProtcolRelationship 
          .where(
            protocol_relationship_object_id: q.all.pluck(:id),
            protocol_relationship_object_type: q.referenced_klass.name,
            protocol_relationship_object_type: q.referenced_klass.base_class.name,
            protocol_relationship_level_id: replace_protocol_relationship_level_id
          ).find_each do |c|
            c.update(protocol_relationship_level_id:)
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

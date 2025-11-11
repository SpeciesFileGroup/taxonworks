class BiologicalAssociationIndexRefreshJob < ApplicationJob
  queue_as :query_batch_update

  def max_run_time
    2.hours
  end

  def max_attempts
    2
  end

  # @param rebuild_set
  #   arbitrary set name, a random string
  def perform(rebuild_set: nil, user_id: nil)
    raise TaxonWorks::Error, 'no set id to refresh job' if rebuild_set.blank?

    q = BiologicalAssociationIndex.where(rebuild_set:)

    Current.user_id = user_id

    q.all.find_each do |o|

      begin
        o.biological_association.set_biological_association_index
      rescue => ex
        ExceptionNotifier.notify_exception(
          ex,
          data: { project_id:, user_id:, rebuild_set: }
        )
        raise
      end
    end

  end
end

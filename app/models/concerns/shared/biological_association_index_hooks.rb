# Add hooks to ensure record changes trigger re-indexing at BiologicalAssociationIndex.
#
# Models including this concern must implement:
#
#   def biological_association_indices
#     BiologicalAssociationIndex.<select>
#   end
#
module Shared::BiologicalAssociationIndexHooks
  extend ActiveSupport::Concern

  included do

    # @return [Boolean]
    #   When true, will not rebuild biological_association_index.
    #   See also Shared::IsIndexedBiologicalAssociation
    attr_accessor :no_biological_association_index

    after_save_commit :update_biological_association_index, unless: :no_biological_association_index
    before_destroy :update_biological_association_index

    def update_biological_association_index
      t = biological_association_indices.count
      return if t == 0

      rebuild_set = SecureRandom.hex(10)

      begin
        # If the scope is returning every object at this point (arbitrary cutoff), then the scope is badly coded.
        if t > 20_000 && (
            (respond_to?(:project_id) &&
              (t == BiologicalAssociationIndex.where(project_id:).count)
            ) ||
            (!respond_to?(:project_id) && (t == BiologicalAssociationIndex.count))
          )
          raise TaxonWorks::Error
        end

        biological_association_indices.in_batches do |b|
          b.update_all(rebuild_set:) # Mark the set of records requiring rebuild
        end

        priority = case t
                   when 1..100
                     1
                   when 101..1000
                     2
                   else
                     6
                   end

        ::BiologicalAssociationIndexRefreshJob.set(priority:).perform_later(
          rebuild_set:,
          user_id: Current.user_id,
        )

      rescue => e
        ExceptionNotifier.notify_exception(
          e,
          data: {
            message: "Improperly coded scope biological_association_indices rebuild #{self.class.name}",
            object_id: id,
            object_class: self.class.name,
          }
        )
        raise
      end
    end

  end

end

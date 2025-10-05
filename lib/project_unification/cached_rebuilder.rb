# Rebuilds cached fields after project unification
#
# Many models cache computed values for performance. After bulk migration,
# these need to be recalculated.
#
module ProjectUnification
  class CachedRebuilder
    attr_reader :project_id

    # Models that have cached fields requiring rebuild
    MODELS_WITH_CACHED_FIELDS = %w[
      TaxonName
      Otu
      CollectionObject
    ].freeze

    def initialize(project_id)
      @project_id = project_id
    end

    # Rebuild all cached fields for models in the project
    # @return [Hash] Rebuild statistics
    def rebuild_all
      stats = {
        models_rebuilt: 0,
        records_updated: 0,
        errors: []
      }

      MODELS_WITH_CACHED_FIELDS.each do |model_name|
        klass = model_name.safe_constantize
        next unless klass

        begin
          count = rebuild_model(klass)
          stats[:models_rebuilt] += 1
          stats[:records_updated] += count
        rescue => e
          stats[:errors] << {
            model: model_name,
            error: e.message
          }
        end
      end

      stats
    end

    private

    def rebuild_model(klass)
      return 0 unless klass.column_names.any? { |c| c.start_with?('cached_') }
      return 0 unless klass.column_names.include?('project_id')

      count = 0

      klass.where(project_id: project_id).find_in_batches(batch_size: 100) do |batch|
        batch.each do |record|
          if record.respond_to?(:set_cached)
            begin
              record.set_cached
              count += 1
            rescue => e
              Rails.logger.error("Failed to rebuild cached for #{klass.name} #{record.id}: #{e.message}")
            end
          end
        end
      end

      count
    end
  end
end

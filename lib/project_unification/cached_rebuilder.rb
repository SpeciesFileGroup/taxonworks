# Rebuilds cached fields after project unification
#
# Many models cache computed values for performance. After bulk migration,
# these need to be recalculated.
#
module ProjectUnification
  class CachedRebuilder
    attr_reader :project_id

    # Models with cached_ columns that DO NOT need rebuilding after unification,
    # and why:
    #
    #   AnatomicalPart     cached_otu_id: OTU primary keys are unchanged by the
    #                        bulk project_id update; moved
    #                        TaxonNameRelationships form a
    #                        self-contained subtree so current_otu resolves
    #                        identically post-unification.
    #                      cached: derives from name/uri_label, project-independent.
    #
    #   CollectingEvent    cached_level*_geographic_name: derives from
    #                        geographic_area_id, which is unchanged.
    #
    #   Descriptor         cached_gene_attribute_sql: derives from gene attribute
    #                        structure, not project context.
    #
    #   GeographicItem     cached_total_area: not project-scoped.
    #
    #   Identifier         cached_numeric_identifier: derives from the identifier
    #                        string value, project-independent.
    #
    #   Observation        cached_column_label, cached_row_label: derive from
    #                        observation matrix column/row labels, which are stable
    #                        strings unchanged by migration.
    #
    #   ObservationMatrixColumn  cached_observation_matrix_column_item_id: stable
    #                        reference whose primary key is unchanged.
    #
    #   ObservationMatrixRow     cached_observation_matrix_row_item_id: same.
    #
    #   SledImage          cached_total_*: counts of associated CollectionObjects,
    #                        which moved intact with their sled_image_id FK.
    #
    #   Source             cached_author_string, cached_nomenclature_date:
    #                        community data, not project-scoped.
    #
    # TODO: the only model we're rebuilding cached_* values on is TaxonName, and
    # it probably isn't needed there either. Confirm.
    MODELS_WITH_CACHED_FIELDS = %w[
      TaxonName
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

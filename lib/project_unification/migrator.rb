# Handles the actual data migration between projects
#
# Processes models in MANIFEST order, applying different strategies
# based on validation complexity (fast/medium/slow tracks).
#
module ProjectUnification
  class Migrator
    attr_reader :source_project_id, :target_project_id, :options

    def initialize(source_project_id, target_project_id, options = {})
      @source_project_id = source_project_id
      @target_project_id = target_project_id
      @options = options
    end

    # Migrate all models from source to target project
    # @return [Hash] Migration results with statistics and errors
    def migrate_all
      results = {
        statistics: {
          models_processed: 0,
          records_migrated: 0,
          fast_track_count: 0,
          medium_track_count: 0,
          slow_track_count: 0,
          special_track_count: 0,
          deduplicated: 0,
          errors_encountered: 0
        },
        details_by_model: {},
        errors: []
      }

      # Process in MANIFEST order (dependencies first)
      # Note: We reverse because MANIFEST is in deletion order
      Project::MANIFEST.reverse.each do |model_name|
        klass = model_name.safe_constantize
        next unless klass
        next unless klass.column_names.include?('project_id')
        next unless ProjectUnification::ModelClassifier.should_migrate?(klass)

        track = ProjectUnification::ModelClassifier.track_for(klass)

        model_result = case track
                       when :fast
                         process_fast_track(klass)
                       when :medium, :implicit
                         process_medium_track(klass)
                       when :slow
                         process_slow_track(klass)
                       when :cached
                         process_cached_table(klass)
                       when :special
                         process_special_handling(klass)
                       else
                         next
                       end

        if model_result
          results[:details_by_model][model_name] = model_result
          results[:statistics][:models_processed] += 1
          results[:statistics][:records_migrated] += model_result[:migrated] || 0

          # Update track-specific counter
          track_key = "#{track}_track_count".to_sym
          results[:statistics][track_key] ||= 0
          results[:statistics][track_key] += model_result[:migrated] || 0

          results[:statistics][:deduplicated] += model_result[:deduplicated] || 0
          results[:statistics][:errors_encountered] += model_result[:errors]&.length || 0
          results[:errors].concat(model_result[:errors] || [])
        end
      end

      results
    end

    private

    # Fast track: Bulk SQL UPDATE for simple cases
    def process_fast_track(klass)
      return nil unless klass.where(project_id: source_project_id).exists?

      sql = ActiveRecord::Base.sanitize_sql_array([
        "UPDATE #{klass.table_name} SET project_id = ? WHERE project_id = ?",
        target_project_id,
        source_project_id
      ])

      rows_affected = ActiveRecord::Base.connection.execute(sql).cmd_tuples

      {
        track: :fast,
        migrated: rows_affected,
        method: :bulk_sql,
        errors: []
      }
    rescue => e
      {
        track: :fast,
        migrated: 0,
        errors: [{
          error: e.message,
          model: klass.name
        }]
      }
    end

    # Medium track: Batch processing with validation
    def process_medium_track(klass)
      stats = { track: :medium, migrated: 0, deduplicated: 0, errors: [] }

      records = klass.where(project_id: source_project_id)
      return nil unless records.exists?

      records.find_in_batches(batch_size: 500) do |batch|
        batch.each do |record|
          record.no_cached = true if record.respond_to?(:no_cached=)
          record.project_id = target_project_id

          if record.valid?
            record.save!(validate: false)
            stats[:migrated] += 1
          elsif uniqueness_error?(record)
            if deduplicate_record(record)
              stats[:migrated] += 1
              stats[:deduplicated] += 1
            else
              stats[:errors] << {
                id: record.id,
                model: klass.name,
                error: 'Failed to deduplicate',
                details: record.errors.full_messages
              }
            end
          else
            stats[:errors] << {
              id: record.id,
              model: klass.name,
              error: record.errors.full_messages.join('; ')
            }
          end
        rescue => e
          stats[:errors] << {
            id: record.id,
            model: klass.name,
            error: e.message
          }
        end
      end

      stats
    end

    # Slow track: Per-record processing with custom handlers
    def process_slow_track(klass)
      stats = { track: :slow, migrated: 0, conflicts: 0, errors: [] }

      records = klass.where(project_id: source_project_id)
      return nil unless records.exists?

      records.find_each do |record|
        record.no_cached = true if record.respond_to?(:no_cached=)
        record.project_id = target_project_id

        if record.valid?
          record.save!
          stats[:migrated] += 1
        elsif uniqueness_error?(record) && record.respond_to?(:handle_unify_conflict)
          record.handle_unify_conflict(target_project_id)
          record.save!
          stats[:migrated] += 1
        elsif uniqueness_error?(record) && deduplicate_record(record)
          stats[:migrated] += 1
        elsif uniqueness_error?(record)
          stats[:errors] << {
            id: record.id,
            model: klass.name,
            error: 'Uniqueness conflict - could not deduplicate'
          }
        else
          stats[:errors] << {
            id: record.id,
            model: klass.name,
            error: record.errors.full_messages.join('; ')
          }
        end
      rescue => e
        stats[:errors] << {
          id: record.id,
          model: klass.name,
          error: e.message
        }
      end

      stats
    end

    # Process cached tables with direct SQL update
    def process_cached_table(klass)
      handler = ProjectUnification::SpecialHandlers::CachedTablesHandler.new(
        source_project_id,
        target_project_id,
        klass.table_name
      )
      handler.migrate
    end

    # Special handling for models that need custom logic
    def process_special_handling(klass)
      result = case klass.name
               when 'TaxonName'
                 handler = ProjectUnification::TaxonNameHandler.new(
                   source_project_id,
                   target_project_id,
                   options
                 )
                 handler.migrate
               when 'CollectingEvent'
                 handler = ProjectUnification::SpecialHandlers::CollectingEventHandler.new(
                   source_project_id,
                   target_project_id,
                   options
                 )
                 handler.migrate
               when 'Image'
                 handler = ProjectUnification::SpecialHandlers::ImageHandler.new(
                   source_project_id,
                   target_project_id,
                   options
                 )
                 handler.migrate
               else
                 raise NotImplementedError, "No special handler defined for #{klass.name}"
               end

      result
    end

    # Check if validation errors are due to uniqueness constraints
    def uniqueness_error?(record)
      record.errors.details.values.flatten.any? { |e| e[:error] == :taken }
    end

    # Attempt to deduplicate a record by finding and merging with existing
    def deduplicate_record(record)
      return false unless record.respond_to?(:identical)

      existing = record.identical.where(project_id: target_project_id).first
      return false unless existing

      # If both records support unify, use it
      if existing.respond_to?(:unify)
        result = existing.unify(record, preview: false)
        return result[:result][:unified] == true
      end

      # Otherwise, try to destroy the duplicate if it has no unique data
      if safe_to_destroy?(record)
        record.destroy
        return true
      end

      false
    rescue => e
      Rails.logger.error("Deduplication failed: #{e.message}")
      false
    end

    # Check if a record can be safely destroyed (has no unique relationships)
    def safe_to_destroy?(record)
      # Very conservative - only destroy if there are no has_many relationships with data
      record.class.reflect_on_all_associations(:has_many).each do |assoc|
        return false if record.send(assoc.name).any?
      end
      true
    end
  end
end

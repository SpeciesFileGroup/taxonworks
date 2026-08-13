# Handles the actual data migration between projects.
#
# Processes models in *reverse* MANIFEST order using two strategies:
#   fast  — bulk SQL UPDATE, no per-record validation
#   slow  — per-record valid? to detect target-project uniqueness conflicts,
#            then save!(validate: false) on success
#
# !! A note on somewhat implicit assumptions as we move objects one at a time
# from source to target project:
# * we run in reverse manifest order: that means that when we validate-save in
#   the target project, any validations that check that FK values are in the
#   same project will pass (aside from the global one we've disabled during
#   unify, are there any such??)
# * when we validate a moved object, some data is still in the source project,
#   so validations like "are there any other objects in this project with this
#   data?" are not seeing all of the data they should - this should be okay
#   because the object is assumed to have already passed that validation in the
#   source project. (If there was bad data in the source, it could stay bad in
#   the target for this reason.)
# * Validations like "make sure all of the children of this object are in the
#   same project" WOULD FAIL when children hadn't been moved to the target
#   project yet. Which is to say !! this system is not bullet proof !!, there
#   are implicit assumptions about how existing validations behave.
require_relative 'special_handlers'

module ProjectUnification
  class Migrator
    attr_reader :source_project_id, :target_project_id, :options

    def initialize(source_project_id:, target_project_id:, options: {})
      @source_project_id = source_project_id
      @target_project_id = target_project_id
      @options = options
      @on_model_migrated = options[:on_model_migrated]
    end

    # Migrate all models from source to target project.
    # @return [Hash] Migration results with statistics and errors
    def migrate_all
      results = {
        statistics: {
          models_processed: 0,
          records_migrated: 0,
          fast_track_count: 0,
          slow_track_count: 0,
          special_track_count: 0,
          errors_encountered: 0
        },
        details_by_model: {},
        conflicts: [],
        errors: [],
        merge_registry: []
      }

      # MANIFEST is ordered for deletion: FK children appear before FK parents so
      # children can be deleted without violating FK constraints. For migration we
      # need the opposite — parents must arrive in the target project before their
      # children, so that when a child calls valid? with project_id = target_project_id
      # any same-project validator on its FK will find the parent already there.
      # Reversing MANIFEST gives us that order cheaply.
      Project::MANIFEST.reverse.each do |model_name|
        klass = model_name.safe_constantize
        next unless klass
        next unless klass.column_names.include?('project_id')
        next unless ProjectUnification::ModelClassifier.should_migrate?(klass)

        track = ProjectUnification::ModelClassifier.track_for(klass)

        model_started_at = Time.now
        model_result = case track
                       when :fast
                         process_fast_track(klass)
                       when :slow
                         process_slow_track(klass)
                       when :cached
                         process_cached_table(klass)
                       when :special
                         process_special_handling(klass)
                       else
                         raise NotImplementedError, "Unknown track #{track.inspect} for #{klass.name}"
                       end

        if model_result
          model_result[:duration] = (Time.now - model_started_at).round(1)
          @on_model_migrated&.call(model_name, track, model_result)

          results[:details_by_model][model_name] = model_result
          results[:statistics][:models_processed] += 1
          results[:statistics][:records_migrated] += model_result[:migrated] || 0

          track_key = "#{track}_track_count".to_sym
          results[:statistics][track_key] ||= 0
          results[:statistics][track_key] += model_result[:migrated] || 0

          results[:statistics][:errors_encountered] += model_result[:errors]&.length || 0
          results[:conflicts].concat(model_result[:conflicts] || [])
          results[:errors].concat(model_result[:errors] || [])
          results[:merge_registry].concat(model_result[:merge_registry] || [])
        end
      end

      results
    end

    private

    # Fast track: Bulk SQL UPDATE for simple cases.
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

    # Slow track: validate each project reassignment, fail on conflict.
    def process_slow_track(klass)
      stats = { track: :slow, migrated: 0, destroyed: 0, conflicts: [], errors: [] }

      records = klass.where(project_id: source_project_id)
      return nil unless records.exists?

      records.find_in_batches do |batch|
        safe_ids = []
        conflict_records = []

        batch.each do |record|
          record.no_cached = true if record.respond_to?(:no_cached=)
          record.project_id = target_project_id

          if record.valid?
            safe_ids << record.id
          elsif uniqueness_error?(record)
            conflict_records << record
          else
            stats[:errors] << {
              id: record.id,
              model: klass.name,
              error: record.errors.full_messages.join('; ')
            }
          end
        rescue => e
          stats[:errors] << { id: record.id, model: klass.name, error: e.message }
        end

        if safe_ids.any?
          stats[:migrated] += klass
            .where(id: safe_ids)
            .update_all(project_id: target_project_id)
        end

        conflict_records.each do |record|
          if record.respond_to?(:handle_unify_conflict)
            apply_conflict_handler(record, stats)
          else
            stats[:conflicts] << {
              id: record.id,
              model: klass.name,
              conflict_fields: conflict_fields(record),
              errors: record.errors.full_messages
            }
          end
        rescue => e
          stats[:errors] << { id: record.id, model: klass.name, error: e.message }
        end
      end

      stats
    end

    # Process cached tables with direct SQL update.
    def process_cached_table(klass)
      handler = ProjectUnification::SpecialHandlers::CachedTablesHandler.new(
        source_project_id:,
        target_project_id:,
        klass:
      )
      handler.migrate
    end

    # Special handling for models that need custom logic.
    def process_special_handling(klass)
      handler_class = case klass.name
      when 'TaxonName' then ProjectUnification::TaxonNameHandler
      when 'CollectingEvent' then ProjectUnification::SpecialHandlers::CollectingEventHandler
      when 'ProjectOrganization' then ProjectUnification::SpecialHandlers::ProjectOrganizationHandler
      when 'ProjectSource' then ProjectUnification::SpecialHandlers::ProjectSourceHandler
      when 'RangedLotCategory' then ProjectUnification::SpecialHandlers::RangedLotCategoryHandler
      when 'OtuPageLayout' then ProjectUnification::SpecialHandlers::OtuPageLayoutHandler
      when 'Image' then ProjectUnification::SpecialHandlers::ImageHandler
      when 'Document' then ProjectUnification::SpecialHandlers::DocumentHandler
      when 'ControlledVocabularyTerm' then ProjectUnification::SpecialHandlers::ControlledVocabularyTermHandler
      else raise NotImplementedError, "No special handler defined for #{klass.name}"
      end

      handler_class.new(source_project_id:, target_project_id:, options:).migrate
    end

    # Dispatch to handle_unify_conflict and update stats based on its return
    # value.
    #
    # handle_unify_conflict return convention:
    #   nil / false  -> handler did not persist; caller should save! the record
    #   true         -> handler persisted via update_columns; skip save!
    #   :destroyed   -> handler destroyed the source record (merged into target); skip save!
    def apply_conflict_handler(record, stats)
      result = record.handle_unify_conflict(target_project_id)

      if result == :destroyed
        stats[:destroyed] += 1
      else
        record.save! unless result
        stats[:migrated] += 1
      end
    end

    def uniqueness_error?(record)
      record.errors.details.values.flatten.any? { |e| e[:error] == :taken }
    end

    def conflict_fields(record)
      record.errors.details
        .select { |_, details| details.any? { |d| d[:error] == :taken } }
        .keys
    end
  end
end
